# -*- encoding : utf-8 -*-

module Jobs
  module Analysis
    # Export a dataset in a given citation format
    #
    # This job fetches the contents of the dataset and offers them to the
    # user for download as bibliographic data.
    class ExportCitations < Jobs::Analysis::Base
      include Resque::Plugins::Status

      # Set the queue for this task
      def self.queue
        :analysis
      end

      # Returns true if this job can be started now
      #
      # @return [Boolean] true
      def self.available?
        true
      end

      # Return how many datasets this job requires
      #
      # @return [Integer] number of datasets needed to perform this job
      def self.num_datasets
        1
      end

      # Export the dataset
      #
      # @api public
      # @param [Hash] options parameters for this job
      # @option options [String] user_id the user whose dataset we are to work on
      # @option options [String] dataset_id the dataset to operate on
      # @option options [String] task_id the analysis task we're working from
      # @option options [String] format the format in which to export
      # @return [undefined]
      # @example Start a job for exporting a datset as JSON
      #   Jobs::Analysis::ExportCitations.create(
      #     user_id: current_user.to_param,
      #     dataset_id: dataset.to_param,
      #     task_id: task.to_param,
      #     format: 'json')
      def perform
        options.symbolize_keys!
        options.remove_blank!
        at(0, 1, 'Initializing...')

        user = User.find(options[:user_id])
        dataset = user.datasets.active.find(options[:dataset_id])
        task = dataset.analysis_tasks.find(options[:task_id])

        # Check that the format is valid (the serializer factory will throw
        # if its not)
        fail ArgumentError, 'Format is not specified' unless options[:format]
        klass = RLetters::Documents::Serializers.for(options[:format])

        # Update the task name
        task.name = t('.short_desc')
        task.save

        # Make a zip file for the output
        total = dataset.entries.count

        ios = ::Zip::OutputStream.write_buffer do |zos|
          dataset.documents.each_with_index do |doc, i|
            at(i, total, "Creating citations: #{i}/#{total}...")

            zos.put_next_entry "#{doc.html_uid}.#{options[:format].to_s}"
            zos.print klass.new(doc).serialize
          end
        end

        # Save it out
        at(total, total, 'Finished, generating output...')
        ios.original_filename = 'export_citations.zip'
        ios.content_type = 'application/zip'
        ios.rewind
        task.result = ios

        # We're done here
        task.finish!

        completed
      end
    end
  end
end
