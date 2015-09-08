
module Datasets
  # A file full of results that belongs to a dataset task
  #
  # As analyses can generate multiple kinds of files, this class encapsulates
  # the content of a database file and its basic description.
  #
  # @!attribute description
  #   @raise [RecordInvalid] if the description is missing (validates :presence)
  #   @return [String] A description of this file's contents
  # @!attribute short_description
  #   @return [String] A short description (for a download button) of this file
  # @!attribute task
  #   @raise [RecordInvalid] if the task is missing (validates :presence)
  #   @return [Datasets::Task] The task to which this file belongs
  #     (`belongs_to`)
  # @!attribute result_file_name
  #   @return [String] The filename of the result file (from Paperclip)
  # @!attribute result_file_size
  #   @return [Integer] The size of the result file (from Paperclip)
  # @!attribute result_content_type
  #   @return [String] The content type of the result file (from Paperclip)
  # @!attribute result_updated_at
  #   @return [DateTime] The last updated time of the result file (from
  #     Paperclip)
  class File < ActiveRecord::Base
    self.table_name = 'datasets_files'

    validates :description, presence: true
    validates :task_id, presence: true

    belongs_to :task, class_name: 'Datasets::Task'

    has_attached_file :result,
                      storage: :database,
                      database_table: 'datasets_file_results'
    validates_attachment_content_type :result,
                                      content_type: /\A(text|application)\/.*\Z/
  end
end
