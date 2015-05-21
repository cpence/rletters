
# Decorate user objects
#
# A few presentation methods for users, mainly converting from database formats
# to actual model objects
class UserDecorator < Draper::Decorator
  delegate_all

  # Get the user's CSL style, converting from `csl_style_id`
  #
  # @return [Users::CslStyle] the user's CSL style (or `nil`)
  def csl_style
    Users::CslStyle.find_by(id: csl_style_id)
  end

  # Get a particular workflow dataset for this user
  #
  # The `workflow_datasets` attribute is an array of ID values, so this will
  # convert them into actual dataset objects.
  #
  # @param [Integer] n the number of the dataset to return
  # @raise [RecordNotFound] if the index is outside the range for the number
  #   of datasets in the user's workflow
  # @return [Dataset] the given dataset
  def workflow_dataset(n)
    fail ActiveRecord::RecordNotFound if workflow_datasets.size <= n
    Dataset.find(workflow_datasets[n])
  end
end
