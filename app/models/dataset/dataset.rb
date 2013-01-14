# -*- encoding : utf-8 -*-

# The saved results of a given search, for analysis
#
# A dataset is the result set from a given search, persisted in the database
# so that we can run digital humanities analyses on a collection of documents.
#
# @attr [String] name The name of this dataset
# @attr [User] user The user that owns this dataset
# @attr [Array<DatasetEntry>] entries The documents contained in this dataset (+has_many+)
# @attr [Array<AnalysisTask>] analysis_tasks The analysis tasks run on this dataset (+has_many+)
class Dataset < ActiveRecord::Base
  validates :name, :presence => true
  validates :user_id, :presence => true
  
  belongs_to :user
  has_many :entries, :class_name => 'DatasetEntry', :dependent => :delete_all
  has_many :analysis_tasks, :dependent => :destroy
  
  validates_associated :entries
  
  attr_accessible :name
end
