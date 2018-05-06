# frozen_string_literal: true

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
  #   @return [Time] The time at which this task was created
  # @!attribute finished_at
  #   @return [Time] The time at which this task was finished
  # @!attribute failed
  #   @return [Boolean] True if this job has failed
  # @!attribute progress
  #   @return [Float] the current progress (from zero to one) of this task
  # @!attribute progress_message
  #   @return [String] the last progress update message from this task
  # @!attribute last_progress
  #   @return [Time] the time of the last progress update
  # @!attribute job_type
  #   @raise [RecordInvalid] if the job type is missing (validates :presence)
  #   @return [String] The class name of the job this task contains
  # @!attribute job_id
  #   @return [String] The ActiveJob UUID for this task, if available
  # @!attribute dataset
  #   @raise [RecordInvalid] if the dataset is missing (validates :presence)
  #   @return [Dataset] The dataset to which this task belongs (`belongs_to`)
  class Task < ApplicationRecord
    self.table_name = 'datasets_tasks'

    validates :name, presence: true
    validates :dataset_id, presence: true
    validates :job_type, presence: true

    belongs_to :dataset
    has_many :files, class_name: 'Datasets::File', dependent: :destroy

    scope :finished, -> { where.not(finished_at: nil) }
    scope :not_finished, -> { where(finished_at: nil) }
    scope :active, -> { not_finished.where(failed: false) }
    scope :failed, -> { not_finished.where(failed: true) }

    # @return [String] string representation of this task
    def to_s
      status = if finished_at.nil?
                 if failed
                   'failed'
                 else
                   "active (#{(progress || 0) * 100.0}%: #{progress_message})"
                 end
               else
                 'finished'
               end

      "#{name} (#{job_type}): #{status}"
    end

    # Get the path for a view template for this job
    #
    # @param [String] template the view path to generate
    # @return [String] the template path to pass to `render`
    def template_path(template)
      class_folder = job_class.name.underscore
      "jobs/#{class_folder}/#{template}"
    end

    # Get the file object with the given content type
    #
    # @param [String] content_type the content type to find
    # @return [Datasets::File] the file object
    def file_for(content_type)
      files.detect { |f| f.result.content_type == content_type }
    end

    # Get the JSON content from a file if available
    #
    # If there is no JSON file attached to this task, this method will return
    # `nil`.
    #
    # @return [String] JSON data as string (or `nil`)
    def json
      file = file_for('application/json')
      file && file.result.download.force_encoding('utf-8')
    end

    # The classes that cannot actually be started as analysis jobs.
    #
    # This array includes both base classes and jobs that are started by the UI
    # or in maintenance queues.
    DISALLOWED_CLASSES = [ApplicationJob, UserExportJob].freeze

    # Convert class_name to a class object
    #
    # @param [String] class_name the class name to convert
    # @return [Class] the job class
    def self.job_class(class_name)
      class_name.safe_constantize.tap do |klass|
        if klass.nil? || DISALLOWED_CLASSES.include?(klass)
          raise ArgumentError, "#{class_name} is not a valid class"
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
    # @return [void]
    def at(current, total, message)
      return if Time.current.to_i - last_progress.to_i < 5

      self.progress = (current.to_f / total.to_f).bound(0.0, 1.0)
      self.progress_message = message
      self.last_progress = Time.current

      save
    end

    # Mark this task as completed
    #
    # @return [void]
    def mark_completed
      self.failed = false
      self.finished_at = Time.current

      self.progress = 1.0
      self.progress_message = I18n.t('common.progress_finished')
      self.last_progress = Time.current

      finish!
    end

    # Mark the given task as failed
    #
    # @param [String] message if set, will use a customized failure message
    # @return [void]
    def mark_failed(message = nil)
      self.failed = true

      self.progress_message = message || I18n.t('common.progress_generic_fail')
      self.last_progress = Time.current

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
        .job_finished_email(dataset.user.email, self)
        .deliver_later(queue: :maintenance)
    end
  end
end
