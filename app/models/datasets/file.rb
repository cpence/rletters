# frozen_string_literal: true

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
  # @!attribute downloadable
  #   @return [Boolean] If true, this file can be downloaded by the end user
  #     (default is `false`)
  # @!attribute result
  #   @return [ActiveStorage::Blob] The result file
  class File < ApplicationRecord
    self.table_name = 'datasets_files'

    validates :description, presence: true
    validates :task_id, presence: true

    belongs_to :task, class_name: 'Datasets::Task'

    has_one_attached :result

    scope :downloadable, -> { where(downloadable: true) }

    # Set the contents of the file from the given string
    #
    # @param [String] content the content for the file
    # @param [Hash] options parameters for the file
    # @option options [String] :filename the name of the file
    # @option options [String] :content_type the file's content type
    def from_string(content, options = {})
      blob = ActiveStorage::Blob.create_after_upload!(
        io: StringIO.new(content),
        filename: options[:filename] || 'download.txt',
        content_type: options[:content_type] || 'text/plain'
      )

      self.result.attach(blob)
      save!
    end
  end
end
