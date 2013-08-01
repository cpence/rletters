# -*- encoding : utf-8 -*-

# A single document belonging to a dataset
#
# We represent the content of datasets as a simple list of shasums, stored
# in a separate database table.
#
# @!attribute shasum
#   @raise [RecordInvalid] if the SHA-1 checksum is missing (validates :presence)
#   @raise [RecordInvalid] if the SHA-1 checksum is not 40 characters (validates :length)
#   @raise [RecordInvalid] if the SHA-1 checksum contains invalid characters (validates :format)
#   @return [String] The SHA-1 checksum of the document represented here
# @!attribute dataset
#   @return [Dataset] The dataset this entry belongs to
class DatasetEntry < ActiveRecord::Base
  validates :shasum, :presence => true
  validates :shasum, :length => { :is => 40 }
  validates :shasum, :format => { :with => /\A[a-fA-F\d]+\z/ }

  # Do *not* validate the dataset association here.  Since datasets and
  # their associated entries are always created at the same time, the
  # validation will fail, as the dataset hasn't yet been saved.

  belongs_to :dataset
end
