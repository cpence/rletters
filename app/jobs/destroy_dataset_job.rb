
# Destroy a user's datset
#
# This job destroys a given dataset.  This SQL call can be quite expensive,
# so we perform it in the background.
class DestroyDatasetJob < ActiveJob::Base
  queue_as :ui

  # Destroy a dataset
  #
  # @param [Dataset] dataset the dataset to be destroyed
  # @return [void]
  def perform(dataset)
    dataset.destroy
  end
end
