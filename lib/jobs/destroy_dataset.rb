# -*- encoding : utf-8 -*-

module Jobs
  # Destroy a user's datset
  #
  # This job destroys a given dataset.  This SQL call can be quite expensive,
  # so we perform it in the background.
  class DestroyDataset
    include Resque::Plugins::Status

    # Set the queue for this task
    def self.queue
      :ui
    end

    # Destroy a dataset
    #
    # @api public
    # @param options parameters for this job
    # @option options [String] :user_id the user that owns this dataset
    # @option options [String] :dataset_id the id of the dataset to be destroyed
    # @return [void]
    # @example Start a job for destroying a dataset
    #   Jobs::DestroyDataset.create(user_id: users(:john).to_param,
    #                               dataset_id: dataset.to_param)
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
