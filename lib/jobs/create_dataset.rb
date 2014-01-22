# -*- encoding : utf-8 -*-

module Jobs
  # Create a dataset from a Solr query for a given user
  #
  # This job fetches results from the Solr server and spools them into the
  # database, creating a dataset for a user.
  class CreateDataset
    include Resque::Plugins::Status

    # Set the queue for this task
    def self.queue
      :ui
    end

    # Create a dataset for the user (filling in an extant template)
    #
    # @api public
    # @param [Hash] options the arguments for this job
    # @option options [String] user_id the user that created this dataset
    # @option options [String] dataset_id the dataset to fill in
    # @option options [String] q the Solr query for this search
    # @option options [Array<String>] fq faceted browsing parameters for
    #   this search
    # @option options [String] def_type parser type for this search
    # @return [undefined]
    # @example Start a job for creating a dataset
    #   dataset = users(:john).datasets.create(disabled: true,
    #                                          name: 'A Dataset')
    #   Jobs::CreateDataset.create(user_id: users(:john).to_param,
    #                              dataset_id: dataset.to_param,
    #                              q: '*:*'
    #                              fq: ['authors_facet:"Shatner"'],
    #                              def_type: 'lucene')
    def perform
      options.symbolize_keys!
      at(0, 1, 'Initializing...')

      user = User.find(options[:user_id])
      dataset = user.datasets.find(options[:dataset_id])

      # Build a Solr query to fetch the results, 1000 at a time
      solr_query = {}
      solr_query[:start] = 0
      solr_query[:rows] = 1000
      solr_query[:q] = options[:q]
      solr_query[:fq] = options[:fq]
      solr_query[:def_type] = options[:def_type]

      # Only get uid and external URLs, no facets
      solr_query[:fl] = 'uid,fulltext_url'
      solr_query[:facet] = false

      # For the status messages
      total = 1

      # We trap all of this so that if we get exceptions we can clean them
      # up and delete any and all fledgling dataset parts
      begin
        # Get the first Solr response
        search_result = RLetters::Solr::Connection.search solr_query

        # Get our parameters
        total = search_result.num_hits
        remaining = total
        dataset_id = dataset.to_param

        while remaining > 0
          at(total - remaining, total, "Fetching documents: #{remaining} left to add...")

          # What did we get this time?
          docs_fetched = search_result.documents.count

          # Send them all in with activerecord-import
          Datasets::Entry.import([:uid, :dataset_id],
                                 search_result.documents.map do |d|
                                   [d.uid, dataset_id]
                                 end,
                                 validate: false)

          # Check to see if there's any externally fetched documents here
          unless dataset.fetch
            if search_result.documents.any? { |d| d.fulltext_url }
              dataset.fetch = true
            end
          end

          # Update counters and execute another query if required
          remaining -= docs_fetched
          if remaining > 0
            solr_query[:start] = solr_query[:start] + docs_fetched
            search_result = RLetters::Solr::Connection.search solr_query
          end
        end

        # Clear the disabled attribute
        dataset.disabled = false
        dataset.save
      rescue StandardError
        # Don't leave an empty dataset around under any circumstances
        dataset.destroy
        raise
      end

      # Link this to the user's workflow if there's one active
      at(total, total, 'Finished creating, saving dataset...')
      user.reload
      if user.workflow_active
        user.workflow_datasets ||= '[]'
        new_datasets = JSON.parse(user.workflow_datasets)
        new_datasets << dataset.to_param
        user.workflow_datasets = new_datasets.to_json

        user.save
      end

      completed
    end
  end
end
