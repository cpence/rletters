# -*- encoding : utf-8 -*-

module Jobs
  module Analysis
    # Plot occurrences of a term in a dataset by year
    class TermDates < Jobs::Analysis::Base
      include Resque::Plugins::Status

      # Set the queue for this task
      #
      # @return [Symbol] the queue on which this job should run
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
      # @option options [String] :user_id the user whose dataset we are to
      #   work on
      # @option options [String] :dataset_id the dataset to operate on
      # @option options [String] :task_id the analysis task we're working from
      # @option options [String] :term the focal word to analyze
      # @return [void]
      # @example Start a job for plotting a dataset by year
      #   Jobs::Analysis::TermDates.create(user_id: current_user.to_param,
      #                                    dataset_id: dataset.to_param,
      #                                    task_id: task.to_param,
      #                                    term: 'test')
      def perform
        options.clean_options!
        at(0, 100, t('common.progress_initializing'))

        user = User.find(options[:user_id])
        dataset = user.datasets.active.find(options[:dataset_id])
        task = dataset.analysis_tasks.find(options[:task_id])

        task.name = t('.short_desc')
        task.save

        # Get the counts and normalize if requested
        term = options[:term]
        analyzer = RLetters::Analysis::CountTermsByField.new(
          term,
          dataset,
          ->(p) { at(p, 100, t('.progress_computing')) })
        dates = analyzer.counts_for(:year)

        dates = dates.to_a
        dates.each { |d| d[0] = Integer(d[0]) }

        # Fill in zeroes for any years that are missing
        at(100, 100, t('common.progress_finished'))
        dates = Range.new(*(dates.map { |d| d[0] }.minmax)).each.map do |y|
          dates.assoc(y) || [ y, 0 ]
        end

        # Save out the data
        output = { data: dates, term: term }

        # Serialize out to JSON
        ios = StringIO.new(output.to_json)
        file = Paperclip.io_adapters.for(ios)
        file.original_filename = 'term_dates.json'
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
