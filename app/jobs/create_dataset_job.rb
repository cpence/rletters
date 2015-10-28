
# Create a dataset from a Solr query for a given user
#
# This job fetches results from the Solr server and spools them into the
# database, creating a dataset for a user.
class CreateDatasetJob < ActiveJob::Base
  queue_as :ui

  # Create a dataset for the user (filling in an extant template)
  #
  # @param [Dataset] dataset the dataset to fill in
  # @param [String] q the Solr query for this search
  # @param [Array<String>] fq faceted browsing parameters for this search
  # @param [String] def_type parser type for this search
  # @return [void]
  def perform(dataset, q, fq, def_type)
    RLetters::Datasets::AddSearch.new(dataset, q, fq, def_type).call

    # Link this to the user's workflow if there's one active
    dataset.user.reload
    if dataset.user.workflow_active
      dataset.user.workflow_datasets << dataset.to_param
      dataset.user.save
    end
  end
end
