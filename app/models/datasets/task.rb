
# Code for objects belonging to datasets
module Datasets
  # An task run on a dataset
  #
  # While the processing is actually occurring in a background job, we
  # need a way for those jobs to communicate with users via the web
  # front-end.  This model is how they do so.
  #
  # @!attribute name
  #   @raise [RecordInvalid] if the name is missing (validates :presence)
  #   @return [String] The name of this task
  # @!attribute created_at
  #   @return [DateTime] The time at which this task was created
  # @!attribute finished_at
  #   @return [DateTime] The time at which this task was finished
  # @!attribute failed
  #   @return [Boolean] True if this job has failed
  # @!attribute progress
  #   @return [Float] the current progress (from zero to one) of this task
  # @!attribute progress_message
  #   @return [String] the last progress update message from this task
  # @!attribute last_progress
  #   @return [DateTime] the time of the last progress update
  # @!attribute job_type
  #   @raise [RecordInvalid] if the job type is missing (validates :presence)
  #   @return [String] The class name of the job this task contains
  # @!attribute dataset
  #   @raise [RecordInvalid] if the dataset is missing (validates :presence)
  #   @return [Dataset] The dataset to which this task belongs (`belongs_to`)
  # @!attribute result_file_name
  #   @return [String] The filename of the result file (from Paperclip)
  # @!attribute result_file_size
  #   @return [Integer] The size of the result file (from Paperclip)
  # @!attribute result_content_type
  #   @return [String] The content type of the result file (from Paperclip)
  # @!attribute result_updated_at
  #   @return [DateTime] The last updated time of the result file (from
  #     Paperclip)
  class Task < ActiveRecord::Base
    self.table_name = 'datasets_tasks'
    serialize :params, Hash

    validates :name, presence: true
    validates :dataset_id, presence: true
    validates :job_type, presence: true

    belongs_to :dataset
    has_attached_file :result, database_table: 'datasets_task_results'
    validates_attachment_content_type :result,
                                      content_type: /\A(text|application)\/.*\Z/

    scope :finished, -> { where.not(finished_at: nil) }
    scope :not_finished, -> { where(finished_at: nil) }
    scope :active, -> { not_finished.where(failed: false) }
    scope :failed, -> { not_finished.where(failed: true) }

    DISALLOWED_CLASSES = [BaseJob, CSVJob, CreateDatasetJob,
                          DestroyDatasetJob, ExpireTasksJob]

    # Convert class_name to a class object
    #
    # @param [String] class_name the class name to convert
    # @return [Class] the job class
    def self.job_class(class_name)
      class_name.safe_constantize.tap do |klass|
        if klass.nil? || DISALLOWED_CLASSES.include?(klass)
          fail ArgumentError, "#{class_name} is not a valid class"
        end
      end
    end

    # Convert #job_type into a class object
    #
    # @return [Class] the job class
    def job_class
      self.class.job_class(job_type)
    end

    # Update the status of this task
    #
    # @param [Numeric] current the current value of the progress counter
    # @param [Numeric] total the total value for the progress counter
    # @param [String] message the current progress message
    def at(current, total, message)
      return if DateTime.now.to_i - self.last_progress.to_i < 5

      self.progress = (current.to_f / total.to_f).bound(0.0, 1.0)
      self.progress_message = message
      self.last_progress = DateTime.now

      save
    end

    # Mark this task as completed
    def mark_completed
      self.failed = false
      self.finished_at = DateTime.current

      self.progress = 1.0
      self.progress_message = I18n.t('common.progress_finished')
      self.last_progress = DateTime.now

      finish!
    end

    # Mark the given task as failed
    def mark_failed(message = nil)
      self.failed = true

      self.progress_message = message || I18n.t('common.progress_generic_fail')
      self.last_progress = DateTime.now

      finish!
    end

    private

    # Hook to be called whenever a job finishes
    #
    # This hook will set the finished attribute on the job and send a
    # notification e-mail to the user.
    #
    # @return [void]
    def finish!
      # Make sure the task is saved
      save

      # Send the user an e-mail
      UserMailer
        .job_finished_email(dataset.user.email, to_param)
        .deliver_later(queue: :maintenance)
    end
  end
end
