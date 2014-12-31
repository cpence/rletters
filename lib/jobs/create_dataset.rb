
# Namespace which contains all background job code
module Jobs
  # Create a dataset from a Solr query for a given user
  #
  # This job fetches results from the Solr server and spools them into the
  # database, creating a dataset for a user.
  class CreateDataset
    include Resque::Plugins::Status

    # Set the queue for this task
    #
    # @return [Symbol] the queue on which this job should run
    def self.queue
      :ui
    end

    # Create a dataset for the user (filling in an extant template)
    #
    # @param [Hash] options the arguments for this job
    # @option options [String] :user_id the user that created this dataset
    # @option options [String] :dataset_id the dataset to fill in
    # @option options [String] :q the Solr query for this search
    # @option options [Array<String>] :fq faceted browsing parameters for
    #   this search
    # @option options [String] :def_type parser type for this search
    # @return [void]
    def perform
      options.symbolize_keys!
      at(0, 1, I18n.t('common.progress_initializing'))

      user = User.find(options[:user_id])
      dataset = user.datasets.find(options[:dataset_id])

      adder = RLetters::Datasets::AddSearch.new(
        dataset,
        options[:q],
        options[:fq],
        options[:def_type],
        ->(p) { at(p, 100, I18n.t('jobs.create_dataset.progress_fetching')) }
      )

      adder.call

      # Link this to the user's workflow if there's one active
      at(100, 100, I18n.t('jobs.create_dataset.progress_finished'))
      user.reload
      if user.workflow_active
        user.workflow_datasets ||= []
        user.workflow_datasets << dataset
        user.save
      end

      completed
    end
  end
end
