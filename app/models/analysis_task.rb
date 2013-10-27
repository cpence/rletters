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
# @!attribute params
#   @return [Hash] The parameters used to start this task with Resque
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
# @!attribute result_file_name
#   @return [String] The filename of the result file (from Paperclip)
# @!attribute result_file_size
#   @return [Integer] The size of the result file (from Paperclip)
# @!attribute result_content_type
#   @return [String] The content type of the result file (from Paperclip)
# @!attribute result_updated_at
#   @return [DateTime] The last updated time of the result file (from
#     Paperclip)
class AnalysisTask < ActiveRecord::Base
  serialize :params, Hash

  validates :name, presence: true
  validates :dataset_id, presence: true
  validates :job_type, presence: true

  belongs_to :dataset
  has_attached_file :result, database_table: 'analysis_task_results'

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
    begin
      klass = "Jobs::Analysis::#{class_name}".constantize

      unless klass.is_a?(Class)
        fail ArgumentError, "#{class_name} is not a class"
      end
    rescue NameError
      raise ArgumentError, "#{class_name} is not a valid class"
    end

    # Never let the 'Base' class match
    if klass == Jobs::Analysis::Base
      fail ArgumentError, 'cannot instantiate the Base job'
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

  # Hook to be called whenever a job finishes
  #
  # This hook will set the finished attribute on the job and send a
  # notification e-mail to the user.
  #
  # @api private
  # @return [undefined]
  def finish!
    # Make sure the task is saved, setting 'finished_at'
    self.finished_at = DateTime.current
    save

    # Send the user an e-mail
    UserMailer.job_finished_email(dataset.user.email, to_param).deliver
  end
end
