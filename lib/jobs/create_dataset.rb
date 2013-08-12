# -*- encoding : utf-8 -*-

module Jobs

  # Create a dataset from a Solr query for a given user
  #
  # This job fetches results from the Solr server and spools them into the
  # database, creating a dataset for a user.
  #
  # @!attribute user_id
  #   @return [String] the user that created this dataset
  # @!attribute name
  #   @return [String] the name of the dataset to create
  # @!attribute q
  #  @return [String] the Solr query for this search
  # @!attribute fq
  #  @return [Array<String>] faceted browsing parameters for this search
  # @!attribute qt
  #  @return [String] query type of this search
  class CreateDataset < Jobs::Base
    attr_accessor :user_id, :name, :q, :fq, :qt

    # Create a dataset for the user
    #
    # @api public
    # @return [undefined]
    # @example Start a job for creating a dataset
    #   Delayed::Job.enqueue Jobs::CreateDataset.new(
    #     user_id: users(:john).to_param,
    #     name: 'Test Dataset',
    #     q: '*:*'
    #     fq: ['authors_facet:"Shatner"'],
    #     qt: 'precise')
    def perform
      # Fetch the user based on ID
      user = User.find(user_id)
      raise ArgumentError, 'User ID is not valid' unless user

      # Create a dataset and save it, to fix its ID
      dataset = user.datasets.build(name: name)
      raise StandardError, 'Cannot create dataset for user' unless dataset
      raise StandardError, 'Cannot save dataset' unless dataset.save

      # Build a Solr query to fetch the results, 1000 at a time
      solr_query = {}
      solr_query[:start] = 0
      solr_query[:rows] = 1000
      solr_query[:q] = q
      solr_query[:fq] = fq
      solr_query[:qt] = qt

      # Only get shasum, no facets
      solr_query[:fl] = 'shasum'
      solr_query[:facet] = false

      # We trap all of this so that if we get exceptions we can clean them
      # up and delete any and all fledgling dataset parts
      begin
        # Get the first Solr response
        search_result = Solr::Connection.find solr_query

        # Get our parameters
        docs_to_fetch = search_result.num_hits
        dataset_id = dataset.to_param

        while docs_to_fetch > 0
          # What did we get this time?
          docs_fetched = search_result.documents.count

          # Send them all in with activerecord-import
          DatasetEntry.import([:shasum, :dataset_id],
                              search_result.documents.map do |d|
                                [d.shasum, dataset_id]
                              end,
                              validate: false)

          # Update counters and execute another query if required
          docs_to_fetch = docs_to_fetch - docs_fetched
          if docs_to_fetch > 0
            solr_query[:start] = solr_query[:start] + docs_fetched
            search_result = Solr::Connection.find solr_query
          end
        end
      rescue StandardError
        # Destroy the dataset to clean up
        dataset.destroy
        raise
      end
    end
  end
end
