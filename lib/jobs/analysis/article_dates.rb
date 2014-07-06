# -*- encoding : utf-8 -*-

module Jobs
  module Analysis
    # Plot a dataset's members by year
    class ArticleDates < Jobs::Analysis::Base
      include Resque::Plugins::Status
      add_concern 'NormalizeDocumentCounts'

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

      # Export the date format data
      #
      # Like all view/multiexport jobs, this job saves its data out as a JSON
      # file and then sends it to the user in various formats depending on
      # user selectons.
      #
      # @api public
      # @param [Hash] options parameters for this job
      # @option options [String] :user_id the user whose dataset we are to work on
      # @option options [String] :dataset_id the dataset to operate on
      # @option options [String] :task_id the analysis task we're working from
      # @return [void]
      # @example Start a job for plotting a dataset by year
      #   Jobs::Analysis::ArticleDates.create(user_id: current_user.to_param,
      #                                       dataset_id: dataset.to_param,
      #                                       task_id: task.to_param)
      def perform
        options.clean_options!
        at(0, 100, t('common.progress_initializing'))

        user = User.find(options[:user_id])
        dataset = user.datasets.active.find(options[:dataset_id])
        task = dataset.analysis_tasks.find(options[:task_id])

        task.name = t('.short_desc')
        task.save

        # Get the counts and normalize if requested
        analyzer = RLetters::Analysis::CountArticlesByField.new(
          dataset,
          ->(p) { at((p.to_f / 100.0 * 90.0).to_i, 100,
                     t('.progress_counting')) })
        dates = analyzer.counts_for(:year)

        at(90, 100, t('.progress_normalizing'))
        dates = normalize_document_counts(user, :year, dates, options)

        dates = dates.to_a
        dates.each { |d| d[0] = Integer(d[0]) }

        # Fill in zeroes for any years that are missing
        at(95, 100, t('.progress_missing'))
        dates = Range.new(*(dates.map { |d| d[0] }.minmax)).each.map do |y|
          dates.assoc(y) || [ y, 0 ]
        end

        # Save out the data, including getting the name of the normalization
        # set for pretty display
        at(100, 100, t('common.progress_finished'))

        norm_set_name = ''
        if options[:normalize_doc_counts] == '1'
          if options[:normalize_doc_dataset]
            norm_set = user.datasets.active.find(options[:normalize_doc_dataset])
            norm_set_name = norm_set.name
          else
            norm_set_name = t('.entire_corpus')
          end
        end

        output = { data: dates,
                   percent: (options[:normalize_doc_counts] == '1'),
                   normalization_set: norm_set_name
                 }

        # Serialize out to JSON
        ios = StringIO.new(output.to_json)
        file = Paperclip.io_adapters.for(ios)
        file.original_filename = 'article_dates.json'
        file.content_type = 'application/json'

        task.result = file

        # We're done here
        task.finish!

        completed
      end

      # We don't want users to download the JSON file
      def self.download?
        false
      end
    end
  end
end
