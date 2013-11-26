# -*- encoding : utf-8 -*-

# A single document belonging to a dataset
#
# We represent the content of datasets as a simple list of ids, stored
# in a separate database table.
#
# @!attribute uid
#   @raise [RecordInvalid] if the uid is missing (validates :presence)
#   @return [String] The uid of the document represented here
# @!attribute dataset
#   @return [Dataset] The dataset this entry belongs to
class Datasets::Entry < ActiveRecord::Base
  self.table_name = 'datasets_entries'
  validates :uid, presence: true

  # Do *not* validate the dataset association here.  Since datasets and
  # their associated entries are always created at the same time, the
  # validation will fail, as the dataset hasn't yet been saved.

  belongs_to :dataset
end
