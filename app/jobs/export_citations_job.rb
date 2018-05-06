# frozen_string_literal: true

# Export a dataset in a given citation format
#
# This job fetches the contents of the dataset and offers them to the
# user for download as bibliographic data.
class ExportCitationsJob < ApplicationJob
  queue_as :analysis

  # Returns true if this job can be started now
  #
  # @return [Boolean] true if this job is not disabled
  def self.available?
    ENV['EXPORT_CITATIONS_JOB_DISABLED'].nil?
  end

  # Export the dataset
  #
  # @param [Datasets::Task] task the task we're working from
  # @param [Hash] options parameters for this job
  # @option options [String] :format the format in which to export
  # @return [void]
  def perform(task, options)
    standard_options(task, options)
    klass = RLetters::Documents::Serializers::Base.for(options[:format])

    # Make a zip file for the output
    total = dataset.document_count

    ios = ::Zip::OutputStream.write_buffer(StringIO.new) do |zos|
      enum = RLetters::Datasets::DocumentEnumerator.new(dataset: dataset)
      enum.each_with_index do |doc, i|
        task.at(i, total, t('.progress_creating', progress: "#{i}/#{total}"))

        zos.put_next_entry "#{doc.uid.html_id}.#{options[:format]}"
        zos.print klass.new(doc).serialize
      end
    end
    ios.rewind

    # Save it out
    blob = ActiveStorage::Blob.create_after_upload!(
      io: ios,
      filename: 'export_citations.zip',
      content_type: 'application/zip'
    )

    task.files.create(description: 'Exported Citations (ZIP)',
                      short_description: 'Download',
                      result: blob, downloadable: true)
    task.mark_completed
  end
end
