# -*- encoding : utf-8 -*-

module Jobs

  # Destroy a user's datset
  #
  # This job destroys a given dataset.  This SQL call can be quite expensive,
  # so we perform it in the background.
  class DestroyDataset
    @queue = 'ui'

    # Destroy a dataset
    #
    # @api public
    # @param args parameters for this job
    # @option args [String] user_id the user that owns this dataset
    # @option args [String] dataset_id the id of the dataset to be destroyed
    # @return [undefined]
    # @example Start a job for destroying a dataset
    #   Resque.enqueue(Jobs::DestroyDataset,
    #                  user_id: users(:john).to_param,
    #                  dataset_id: dataset.to_param)
    def self.perform(args = { })
      args.symbolize_keys!

      # Fetch the user based on ID
      user = User.find(args[:user_id])
      raise ArgumentError, 'User ID is not valid' unless user

      dataset = user.datasets.find(args[:dataset_id])
      raise ArgumentError, 'Dataset ID is not valid' unless dataset

      dataset.destroy
    end
  end
end
