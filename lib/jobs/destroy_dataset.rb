
module Jobs
  # Destroy a user's datset
  #
  # This job destroys a given dataset.  This SQL call can be quite expensive,
  # so we perform it in the background.
  class DestroyDataset
    include Resque::Plugins::Status

    # Set the queue for this task
    #
    # @return [Symbol] the queue on which this job should run
    def self.queue
      :ui
    end

    # Destroy a dataset
    #
    # @param [Hash] options parameters for this job
    # @option options [String] :user_id the user that owns this dataset
    # @option options [String] :dataset_id the id of the dataset to be destroyed
    # @return [void]
    def perform
      options.symbolize_keys!
      tick(I18n.t('jobs.destroy_dataset.progress_destroying'))

      user = User.find(options[:user_id])
      dataset = user.datasets.find(options[:dataset_id])
      dataset.destroy

      completed
    end
  end
end
