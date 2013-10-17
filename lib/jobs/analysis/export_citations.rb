# -*- encoding : utf-8 -*-

module Jobs
  module Analysis

    # Export a dataset in a given citation format
    #
    # This job fetches the contents of the dataset and offers them to the
    # user for download as bibliographic data.
    class ExportCitations < Jobs::Analysis::Base
      @queue = 'analysis'

      # Return the name of this job
      #
      # @return [String] name of this job
      def self.job_name
        'Export Citations'
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
      def self.perform(args = { })
        args.symbolize_keys!

        # Fetch the user based on ID
        user = User.find(args[:user_id])
        fail ArgumentError, 'User ID is not valid' unless user

        # Fetch the dataset based on ID
        dataset = user.datasets.find(args[:dataset_id])
        fail ArgumentError, 'Dataset ID is not valid' unless dataset

        # Grab and update the analysis task
        task = dataset.analysis_tasks.find(args[:task_id])
        fail ArgumentError, 'Task ID is not valid' unless task

        # Check that the format is valid
        fail ArgumentError, 'Format is not specified' unless args[:format]
        serializer = Document.serializers[args[:format].to_sym]
        fail ArgumentError, 'Format is not valid' unless serializer

        # Update the task name
        task.name = "Export as #{serializer[:name]}"
        task.save

        # Make a zip file for the output
        # Pack all those files into a ZIP
        ios = Zip::OutputStream::write_buffer do |zos|
          # find_each will take care of batching logic for us
          dataset.entries.find_each do |e|
            doc = Document.find_by_shasum(e.shasum)
            if doc
              zos.put_next_entry "#{doc.shasum}.#{args[:format].to_s}"
              zos.print serializer[:method].call(doc)
            end
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
