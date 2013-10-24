# -*- encoding : utf-8 -*-

module Jobs
  module Analysis

    # Plot a dataset's members by year
    class PlotDates < Jobs::Analysis::Base
      add_concern 'NormalizeDocumentCounts'
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

      # Export the date format data
      #
      # Like all view/multiexport jobs, this job saves its data out as a JSON
      # file and then sends it to the user in various formats depending on
      # user selectons.
      #
      # @api public
      # @param [Hash] args parameters for this job
      # @option args [String] user_id the user whose dataset we are to work on
      # @option args [String] dataset_id the dataset to operate on
      # @option args [String] task_id the analysis task we're working from
      # @return [undefined]
      # @example Start a job for plotting a dataset by year
      #   Resque.enqueue(Jobs::Analysis::PlotDates,
      #                  user_id: current_user.to_param,
      #                  dataset_id: dataset.to_param,
      #                  task_id: task.to_param)
      def self.perform(args = { })
        args.symbolize_keys!

        # Fetch the user based on ID
        user = User.find(args[:user_id])
        fail ArgumentError, 'User ID is not valid' unless user

        # Fetch the dataset based on ID
        dataset = user.datasets.find(args[:dataset_id])
        fail ArgumentError, 'Dataset ID is not valid' unless dataset

        # Make a new analysis task
        task = dataset.analysis_tasks.find(args[:task_id])
        fail ArgumentError, 'Task ID is not valid' unless task

        task.name = 'Plot dataset by date'
        task.save

        # Get the counts and normalize if requested
        dates = Solr::DataHelpers::count_by_field(dataset, :year)
        dates = normalize_document_counts(user, :year, dates, args)

        dates = dates.to_a
        dates.each { |d| d[0] = Integer(d[0]) }

        # Sort by date
        dates = dates.sort_by { |y| y[0] }

        # Save out the data, including getting the name of the normalization
        # set for pretty display
        normalization_set_name = ''
        if args[:normalize_doc_counts] == '1'
          if args[:normalize_doc_dataset].blank?
            normalization_set_name = 'Entire Corpus'
          else
            normalization_set_name = user.datasets.find(args[:normalize_doc_dataset]).name
          end
        end

        output = { data: dates,
                   percent: (args[:normalize_doc_counts] == '1'),
                   normalization_set: normalization_set_name
                 }

        # Serialize out to JSON
        ios = StringIO.new
        ios.write(output.to_json)
        ios.original_filename = 'plot_dates.json'
        ios.content_type = 'application/json'
        ios.rewind

        task.result = ios
        ios.close

        # We're done here
        task.finish!
      end

      # We don't want users to download the JSON file
      def self.download?
        false
      end
    end

  end
end
