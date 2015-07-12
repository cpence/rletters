
module Jobs
  module Analysis
    # Export a dataset in a given citation format
    #
    # This job fetches the contents of the dataset and offers them to the
    # user for download as bibliographic data.
    class ExportCitations < Jobs::Analysis::Base
      # Export the dataset
      #
      # @param [String] user_id the user whose dataset we are to work on
      # @param [String] dataset_id the dataset to operate on
      # @param [String] task_id the task we're working from
      # @param [Hash] options parameters for this job
      # @option options [String] :format the format in which to export
      # @return [void]
      def self.perform(user_id, dataset_id, task_id, options)
        standard_options(user_id, dataset_id, task_id)

        # Check that the format is valid (the serializer factory will throw
        # if its not)
        options.symbolize_keys!
        fail ArgumentError, 'Format is not specified' unless options[:format]
        klass = RLetters::Documents::Serializers.for(options[:format])

        # Make a zip file for the output
        total = get_dataset(task_id).entries.size

        ios = ::Zip::OutputStream.write_buffer(StringIO.new('')) do |zos|
          enum = RLetters::Datasets::DocumentEnumerator.new(get_dataset(task_id))
          enum.each_with_index do |doc, i|
            get_task(task_id).at(i, total, t('.progress_creating',
                                             progress: "#{i}/#{total}"))

            zos.put_next_entry "#{doc.uid.html_id}.#{options[:format]}"
            zos.print klass.new(doc).serialize
          end
        end
        ios.rewind

        # Save it out
        file = Paperclip.io_adapters.for(ios)
        file.original_filename = 'export_citations.zip'
        file.content_type = 'application/zip'

        task = get_task(task_id)
        task.result = file
        task.mark_completed
      end
    end
  end
end
