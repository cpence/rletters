# -*- encoding : utf-8 -*-

# A single document belonging to a dataset
#
# We represent the content of datasets as a simple list of shasums, stored
# in a separate database table.
#
# @attr [String] shasum The SHA-1 checksum of the document represented here
# @attr [Dataset] dataset The dataset this entry belongs to
class DatasetEntry < ActiveRecord::Base
  validates :shasum, :presence => true
  validates :shasum, :length => { :is => 40 }
  validates :shasum, :format => { :with => /\A[a-fA-F\d]+\z/u }
  
  # Do *not* validate the dataset association here.  Since datasets and
  # their associated entries are always created at the same time, the
  # validation will fail, as the dataset hasn't yet been saved.

  belongs_to :dataset
  
  attr_accessible :shasum
end
