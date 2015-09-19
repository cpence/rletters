
# Export a dataset in a given citation format
#
# This job fetches the contents of the dataset and offers them to the
# user for download as bibliographic data.
class ExportCitationsJob < BaseJob
  # Export the dataset
  #
  # @param [Datasets::Task] task the task we're working from
  # @param [Hash] options parameters for this job
  # @option options [String] :format the format in which to export
  # @return [void]
  def perform(task, options)
    standard_options(task)

    # Check that the format is valid (the serializer factory will throw
    # if its not)
    options = options.with_indifferent_access
    fail ArgumentError, 'Format is not specified' unless options[:format]
    klass = RLetters::Documents::Serializers.for(options[:format])

    # Make a zip file for the output
    total = dataset.entries.size

    ios = ::Zip::OutputStream.write_buffer(StringIO.new('')) do |zos|
      enum = RLetters::Datasets::DocumentEnumerator.new(dataset)
      enum.each_with_index do |doc, i|
        task.at(i, total, t('.progress_creating', progress: "#{i}/#{total}"))

        zos.put_next_entry "#{doc.uid.html_id}.#{options[:format]}"
        zos.print klass.new(doc).serialize
      end
    end
    ios.rewind

    # Save it out
    file = Paperclip.io_adapters.for(ios)
    file.original_filename = 'export_citations.zip'
    file.content_type = 'application/zip'

    task.files.create(description: 'Exported Citations (ZIP)',
                      short_description: 'Download',
                      result: file, downloadable: true)
    task.mark_completed
  end
end
