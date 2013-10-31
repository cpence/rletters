# -*- encoding : utf-8 -*-

module Jobs

  # Create a dataset from a Solr query for a given user
  #
  # This job fetches results from the Solr server and spools them into the
  # database, creating a dataset for a user.
  class CreateDataset
    @queue = 'ui'

    # Create a dataset for the user (filling in an extant template)
    #
    # @api public
    # @param [Hash] args the arguments for this job
    # @option args [String] user_id the user that created this dataset
    # @option args [String] dataset_id the dataset to fill in
    # @option args [String] q the Solr query for this search
    # @option args [Array<String>] fq faceted browsing parameters for
    #   this search
    # @option args [String] defType parser type for this search
    # @return [undefined]
    # @example Start a job for creating a dataset
    #   dataset = users(:john).datasets.create(disabled: true,
    #                                          name: 'A Dataset')
    #   Resque.enqueue(Jobs::CreateDataset.new,
    #                  user_id: users(:john).to_param,
    #                  dataset_id: dataset.to_param,
    #                  q: '*:*'
    #                  fq: ['authors_facet:"Shatner"'],
    #                  defType: 'lucene')
    def self.perform(args = { })
      args.symbolize_keys!

      # Fetch the user based on ID
      user = User.find(args[:user_id])
      fail ArgumentError, 'User ID is not valid' unless user

      # Fetch the dataset
      dataset = user.datasets.find(args[:dataset_id])
      fail ArgumentError, 'Dataset ID is not valid' unless dataset

      # Build a Solr query to fetch the results, 1000 at a time
      solr_query = {}
      solr_query[:start] = 0
      solr_query[:rows] = 1000
      solr_query[:q] = args[:q]
      solr_query[:fq] = args[:fq]
      solr_query[:defType] = args[:defType]

      # Only get uid, no facets
      solr_query[:fl] = 'uid'
      solr_query[:facet] = false

      # We trap all of this so that if we get exceptions we can clean them
      # up and delete any and all fledgling dataset parts
      begin
        # Get the first Solr response
        search_result = Solr::Connection.search solr_query

        # Get our parameters
        docs_to_fetch = search_result.num_hits
        dataset_id = dataset.to_param

        while docs_to_fetch > 0
          # What did we get this time?
          docs_fetched = search_result.documents.count

          # Send them all in with activerecord-import
          DatasetEntry.import([:uid, :dataset_id],
                              search_result.documents.map do |d|
                                [d.uid, dataset_id]
                              end,
                              validate: false)

          # Update counters and execute another query if required
          docs_to_fetch = docs_to_fetch - docs_fetched
          if docs_to_fetch > 0
            solr_query[:start] = solr_query[:start] + docs_fetched
            search_result = Solr::Connection.search solr_query
          end
        end

        # Clear the disabled attribute
        dataset.disabled = false
        dataset.save
      rescue StandardError
        # Destroy the dataset to clean up
        dataset.destroy
        raise
      end

      # Link this to the user's workflow if there's one active
      user.reload
      if user.workflow_active
        new_datasets = JSON.parse(user.workflow_datasets)
        new_datasets << dataset.to_param
        user.workflow_datasets = new_datasets.to_json

        user.save
      end
    end
  end
end
