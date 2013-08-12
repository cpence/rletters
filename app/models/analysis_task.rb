# -*- encoding : utf-8 -*-

# An analysis task run on a dataset
#
# While the processing is actually occurring in a delayed job, we need a way
# for those delayed jobs to readily communicate with users via the web
# front-end.  This model is how they do so.
#
# @!attribute name
#   @raise [RecordInvalid] if the name is missing (validates :presence)
#   @return [String] The name of this task
# @!attribute created_at
#   @return [DateTime] The time at which this task was started
# @!attribute finished_at
#   @return [DateTime] The time at which this task was finished
# @!attribute failed
#   @return [Boolean] True if this job has failed
# @!attribute job_type
#   @raise [RecordInvalid] if the job type is missing (validates :presence)
#   @return [String] The class name of the job this task contains
# @!attribute dataset
#   @raise [RecordInvalid] if the dataset is missing (validates :presence)
#   @return [Dataset] The dataset to which this task belongs (+belongs_to+)
# @!attribute result_file
#   @return [Download] The results of this analysis task, if available
class AnalysisTask < ActiveRecord::Base
  validates :name, presence: true
  validates :dataset_id, presence: true
  validates :job_type, presence: true

  belongs_to :dataset
  has_one :result_file, class_name: 'Download', dependent: :destroy

  scope :finished, -> { where('finished_at IS NOT NULL') }
  scope :not_finished, -> { where('finished_at IS NULL') }
  scope :active, -> { not_finished.where(failed: false) }
  scope :failed, -> { not_finished.where(failed: true) }

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
    fail ArgumentError, 'cannot instantiate the Base job' if class_name == 'Jobs::Analysis::Base'

    begin
      klass = class_name.constantize
      fail ArgumentError, "#{class_name} is not a class" unless klass.is_a?(Class)
    rescue NameError
      raise ArgumentError, "#{class_name} is not a valid class"
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
