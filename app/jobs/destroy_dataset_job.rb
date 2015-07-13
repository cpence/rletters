
# Destroy a user's datset
#
# This job destroys a given dataset.  This SQL call can be quite expensive,
# so we perform it in the background.
class DestroyDatasetJob < ActiveJob::Base
  queue_as :ui

  # Destroy a dataset
  #
  # @param [String] user_id the user that owns this dataset
  # @param [String] dataset_id the id of the dataset to be destroyed
  # @return [void]
  def perform(user_id, dataset_id)
    user = User.find(user_id)
    dataset = user.datasets.find(dataset_id)
    dataset.destroy
  end
end
