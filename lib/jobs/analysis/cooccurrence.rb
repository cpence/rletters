# -*- encoding : utf-8 -*-

module Jobs
  module Analysis
    # Determine statistically significant cooccurrences in text
    class Cooccurrence < Jobs::Analysis::CSVJob
      # Locate significant associations between words at distance.
      #
      # This saves its data out as a CSV file to be downloaded by the user
      # later.
      #
      # @param [Hash] options parameters for this job
      # @option options [String] :user_id the user whose dataset we are to
      #   work on
      # @option options [String] :dataset_id the dataset to operate on
      # @option options [String] :task_id the analysis task we're working from
      # @option options [String] :analysis_type the algorithm to use to
      #   analyze the significance of coocurrences.  Can be `'mi'` (for mutual
      #   information), or `'t'` (for t-test).
      # @option options [String] :num_pairs number of coccurrences to return
      # @option options [String] :window the window for searching for
      #   cooccurrences
      # @option options [String] :word the word to search for cooccurrences
      #   with
      # @return [void]
      # @example Start a job for locating cooccurrences
      #   Jobs::Analysis::Cooccurrence.create(user_id: current_user.to_param,
      #                                       dataset_id: dataset.to_param,
      #                                       task_id: task.to_param,
      #                                       analysis_type: 't',
      #                                       num_pairs: '50',
      #                                       word: 'evolutionary')
      def perform
        at(0, 100, t('common.progress_initializing'))
        standard_options!

        fail ArgumentError, 'No cooccurrence word provided' unless options[:word]

        analysis_type = (options[:analysis_type] || :mi).to_sym
        num_pairs = (options[:num_pairs] || 50).to_i
        word = options[:word].mb_chars.downcase.to_s
        window = (options[:window] || 200).to_i

        case analysis_type
        when :mi
          algorithm = t('.mi')
          column = t('.mi_column')
          klass = RLetters::Analysis::Cooccurrence::MutualInformation
        when :t
          algorithm = t('.t')
          column = t('.t_column')
          klass = RLetters::Analysis::Cooccurrence::TTest
        else
          fail ArgumentError, 'Invalid value for analysis_type'
        end

        analyzer = klass.new(
          @dataset,
          num_pairs,
          word,
          window,
          ->(p) { at(p, 100, t('.progress_computing')) }
        )
        grams = analyzer.call

        # Save out all the data
        at(100, 100, t('common.progress_finished'))
        write_csv(nil, t('.subheader', test: algorithm)) do |csv|
          csv << [t('.pair'), column]
          grams.each do |w, v|
            csv << [w, v]
          end
        end

        # We're done here
        @task.finish!

        completed
      end

      # We don't want users to download the JSON file
      def self.download?
        true
      end

      # Helper method for creating the job parameters view
      #
      # This method returns the list of available significance test methods
      # along with their translated user-friendly names, useful for looping
      # over to display them for the user to choose from.
      #
      # @return [Array<(String, Symbol)>] pairs of test method names and their
      #   associated symbols
      def self.significance_tests
        [:mi, :t].map do |sym|
          [t(".#{sym}"), sym]
        end
      end
    end
  end
end
