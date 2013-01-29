# -*- encoding : utf-8 -*-

# The saved results of a given search, for analysis
#
# A dataset is the result set from a given search, persisted in the database
# so that we can run digital humanities analyses on a collection of documents.
#
# @!attribute name
#   @return [String] The name of this dataset
# @!attribute user
#   @return [User] The user that owns this dataset
# @!attribute entries
#   @return [Array<DatasetEntry>] The documents contained in this dataset (+has_many+)
# @!attribute analysis_tasks
#   @return [Array<AnalysisTask>] The analysis tasks run on this dataset (+has_many+)
class Dataset < ActiveRecord::Base
  validates :name, :presence => true
  validates :user_id, :presence => true
  
  belongs_to :user
  has_many :entries, :class_name => 'DatasetEntry', :dependent => :delete_all
  has_many :analysis_tasks, :dependent => :destroy
  
  validates_associated :entries
  
  attr_accessible :name
end
