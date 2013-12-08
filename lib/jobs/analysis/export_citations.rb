# -*- encoding : utf-8 -*-

module Jobs
  module Analysis
    # Export a dataset in a given citation format
    #
    # This job fetches the contents of the dataset and offers them to the
    # user for download as bibliographic data.
    class ExportCitations < Jobs::Analysis::Base
      @queue = 'analysis'

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
      # @param [Hash] args parameters for this job
      # @option args [String] user_id the user whose dataset we are to work on
      # @option args [String] dataset_id the dataset to operate on
      # @option args [String] task_id the analysis task we're working from
      # @option args [String] format the format in which to export (see
      #   +Document.serializers+)
      # @return [undefined]
      # @example Start a job for exporting a datset as JSON
      #   Resque.enqueue(Jobs::Analysis::ExportCitations,
      #                  user_id: current_user.to_param,
      #                  dataset_id: dataset.to_param,
      #                  task_id: task.to_param,
      #                  format: :json)
      def self.perform(args = {})
        args.symbolize_keys!
        args.remove_blank!

        user = User.find(args[:user_id])
        dataset = user.datasets.active.find(args[:dataset_id])
        task = dataset.analysis_tasks.find(args[:task_id])

        # Check that the format is valid
        fail ArgumentError, 'Format is not specified' unless args[:format]
        serializer = Document.serializers[args[:format].to_sym]
        fail ArgumentError, 'Format is not valid' unless serializer

        # Update the task name
        task.name = t('.short_desc')
        task.save

        # Make a zip file for the output
        # Pack all those files into a ZIP
        ios = ::Zip::OutputStream.write_buffer do |zos|
          dataset.documents.each do |doc|
            zos.put_next_entry "#{doc.html_uid}.#{args[:format].to_s}"
            zos.print serializer[:method].call(doc)
          end
        end

        # Save it out
        ios.original_filename = 'export_citations.zip'
        ios.content_type = 'application/zip'
        ios.rewind
        task.result = ios

        # We're done here
        task.finish!
      end
    end
  end
end
