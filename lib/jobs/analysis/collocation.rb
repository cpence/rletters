# -*- encoding : utf-8 -*-
require 'csv'

module Jobs
  module Analysis
    # Determine statistically significant collocations in text
    class Collocation < Jobs::Analysis::Base
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

      # Locate significant associations between words.
      #
      # This saves its data out as a CSV file to be downloaded by the user
      # later.
      #
      # @param [Hash] options parameters for this job
      # @option options [String] user_id the user whose dataset we are to work on
      # @option options [String] dataset_id the dataset to operate on
      # @option options [String] task_id the analysis task we're working from
      # @option options [String] analysis_type the algorithm to use to analyze the
      #   significance of collocations.  Can be 'mi' (for mutual
      #   information), 't' (for t-test), 'likelihood' (for log-likelihood),
      #   or 'pos' (for part-of-speech biased frequencies).
      # @option options [String] num_pairs number of collocations to return
      # @option options [String] word if present, return only collocations
      #   including this word
      # @return [undefined]
      # @example Start a job for locating collocations
      #   Jobs::Analysis::Collocation.create(user_id: current_user.to_param,
      #                                      dataset_id: dataset.to_param,
      #                                      task_id: task.to_param,
      #                                      analysis_type: 't',
      #                                      num_pairs: '50')
      def perform
        options.clean_options!
        at(0, 100, 'Initializing...')

        user = User.find(options[:user_id])
        @dataset = user.datasets.active.find(options[:dataset_id])
        task = @dataset.analysis_tasks.find(options[:task_id])

        task.name = t('.short_desc')
        task.save

        analysis_type = (options[:analysis_type] || :mi).to_sym
        num_pairs = (options[:num_pairs] || 50).to_i
        focal_word = options[:word].mb_chars.downcase.to_s if options[:word]

        # Part of speech tagging requires the Stanford NLP
        analysis_type = :mi if !NLP_ENABLED && analysis_type == :pos

        case analysis_type
        when :mi
          algorithm = t('.mi')
          column = t('.mi_column')
          klass = RLetters::Analysis::Collocation::MutualInformation
        when :t
          algorithm = t('.t')
          column = t('.t_column')
          klass = RLetters::Analysis::Collocation::TTest
        when :likelihood
          algorithm = t('.likelihood')
          column = t('.likelihood_column')
          klass = RLetters::Analysis::Collocation::LogLikelihood
        when :pos
          # :nocov:
          algorithm = t('.pos')
          column = t('.pos_column')
          klass = RLetters::Analysis::Collocation::PartsOfSpeech
          # :nocov:
        else
          fail ArgumentError, 'Invalid value for analysis_type'
        end

        analyzer = klass.new(
          @dataset,
          num_pairs,
          focal_word,
          ->(p) { at(p, 100, 'Computing collocations for dataset...') }
        )
        grams = analyzer.call

        # Save out all the data
        at(100, 100, 'Finished, generating output...')
        csv_string = CSV.generate do |csv|
          csv << [t('.header', name: @dataset.name)]
          csv << [t('.subheader', test: algorithm)]
          csv << ['']

          csv << [t('.pair'), column]
          grams.each do |w, v|
            csv << [w, v]
          end

          csv << ['']
        end

        # Write it out
        ios = StringIO.new(csv_string)
        file = Paperclip.io_adapters.for(ios)
        file.original_filename = 'collocation.csv'
        file.content_type = 'text/csv'

        task.result = file

        # We're done here
        task.finish!

        completed
      end

      # We don't want users to download the JSON file
      def self.download?
        true
      end

      # Helper method for creating the job parameters view
      #
      # This method returns the list of available significance test methods.
      def self.significance_tests
        [:mi, :t, :likelihood, :pos].map do |sym|
          [t(".#{sym}"), sym]
        end
      end
    end
  end
end
