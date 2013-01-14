# -*- encoding : utf-8 -*-

# An analysis task run on a dataset
#
# While the processing is actually occurring in a delayed job, we need a way
# for those delayed jobs to readily communicate with users via the web
# front-end.  This model is how they do so.
#
# @attr [String] name The name of this task
# @attr [DateTime] created_at The time at which this task was started
# @attr [DateTime] finished_at The time at which this task was finished
# @attr [Boolean] failed True if this job has failed
# @attr [String] job_type The class name of the job this task contains
# @attr [Dataset] dataset The dataset to which this task belongs (+belongs_to+)
# @attr [Download] result_file The results of this analysis task, if available
class AnalysisTask < ActiveRecord::Base
  validates :name, :presence => true
  validates :dataset_id, :presence => true
  validates :job_type, :presence => true

  belongs_to :dataset
  has_one :result_file, :class_name => 'Download', :dependent => :destroy
  
  attr_accessible :name, :dataset, :job_type
  
  scope :finished, where('finished_at IS NOT NULL')
  scope :not_finished, where('finished_at IS NULL')
  scope :active, not_finished.where(:failed => false)
  scope :failed, not_finished.where(:failed => true)
  
  # Convert class_name to a class object
  #
  # @api public
  # @param [String] class_name the class name to convert
  # @return [Class] the job class
  # @example Call the view_path method for ExportCitations
  #   AnalysisTask.job_class('ExportCitations').view_path(...)
  def self.job_class(class_name)
    # Never let the 'Base' class match
    class_name = 'Jobs::Analysis::' + class_name
    raise ArgumentError if class_name == 'Jobs::Analysis::Base'
    
    begin
      klass = class_name.constantize
      raise ArgumentError unless klass.is_a?(Class)
    rescue NameError
      raise ArgumentError
    end
    
    klass
  end
  
  # Convert #job_type into a class object
  #
  # @api public
  # @return [Class] the job class
  # @example Call the view_path method for this task
  #   task.job_class.view_path(...)
  def job_class
    self.class.job_class(job_type)
  end
end
