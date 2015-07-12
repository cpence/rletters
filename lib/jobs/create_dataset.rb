
# Namespace which contains all background job code
module Jobs
  # Create a dataset from a Solr query for a given user
  #
  # This job fetches results from the Solr server and spools them into the
  # database, creating a dataset for a user.
  class CreateDataset
    # Set the queue for this task
    #
    # @return [Symbol] the queue on which this job should run
    def self.queue
      :ui
    end

    # Create a dataset for the user (filling in an extant template)
    #
    # @param [String] user_id the user that created this dataset
    # @param [String] dataset_id the dataset to fill in
    # @param [String] q the Solr query for this search
    # @param [Array<String>] fq faceted browsing parameters for this search
    # @param [String] def_type parser type for this search
    # @return [void]
    def self.perform(user_id, dataset_id, q, fq, def_type)
      user = User.find(user_id)
      dataset = user.datasets.find(dataset_id)

      adder = RLetters::Datasets::AddSearch.new(dataset, q, fq, def_type)
      adder.call

      # Link this to the user's workflow if there's one active
      user.reload
      if user.workflow_active
        user.workflow_datasets << dataset.to_param
        user.save
      end
    end
  end
end
