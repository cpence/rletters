
module Jobs
  module Analysis
    # Determine statistically significant collocations in text
    class Collocation < Jobs::Analysis::CSVJob
      # Locate significant associations between words.
      #
      # This saves its data out as a CSV file to be downloaded by the user
      # later.
      #
      # @param [String] user_id the user whose dataset we are to work on
      # @param [String] dataset_id the dataset to operate on
      # @param [String] task_id the task we're working from
      # @param [Hash] options parameters for this job
      # @option options [String] :analysis_type the algorithm to use to
      #   analyze the significance of collocations.  Can be `'mi'` (for mutual
      #   information), `'t'` (for t-test), `'likelihood'` (for
      #   log-likelihood), or `'pos'` (for part-of-speech biased frequencies).
      # @option options [String] :num_pairs number of collocations to return
      # @option options [String] :word if present, return only collocations
      #   including this word
      # @return [void]
      def self.perform(user_id, dataset_id, task_id, options = {})
        standard_options(user_id, dataset_id, task_id)

        options.symbolize_keys!
        analysis_type = (options[:analysis_type] || :mi).to_sym
        if options[:all] == '1'
          num_pairs = 0
        else
          num_pairs = (options[:num_pairs] || 50).to_i
        end
        focal_word = options[:word].mb_chars.downcase.to_s if options[:word]

        # Part of speech tagging requires the Stanford NLP
        if analysis_type == :pos && Admin::Setting.nlp_tool_path.blank?
          analysis_type = :mi
        end

        case analysis_type
        when :mi
          algorithm = t('common.scoring.mi')
          column = t('common.scoring.mi_header')
          klass = RLetters::Analysis::Collocation::MutualInformation
        when :t
          algorithm = t('common.scoring.t')
          column = t('common.scoring.t_header')
          klass = RLetters::Analysis::Collocation::TTest
        when :likelihood
          algorithm = t('common.scoring.likelihood')
          column = t('common.scoring.likelihood_header')
          klass = RLetters::Analysis::Collocation::LogLikelihood
        when :pos
          algorithm = t('.pos')
          column = t('.pos_header')
          klass = RLetters::Analysis::Collocation::PartsOfSpeech
        else
          fail ArgumentError, 'Invalid value for analysis_type'
        end

        analyzer = klass.new(
          get_dataset(task_id),
          num_pairs,
          focal_word,
          ->(p) { get_task(task_id).at(p, 100, t('.progress_computing')) }
        )
        grams = analyzer.call

        # Save out all the data
        write_csv_and_complete(task_id, nil,
                               t('.subheader', test: algorithm)) do |csv|
          csv << [t('.pair'), column]
          grams.each do |w, v|
            csv << [w, v]
          end
        end
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
        [:mi, :t, :likelihood, :pos].map do |sym|
          if sym == :pos
            [t('.pos'), :pos]
          else
            [t("common.scoring.#{sym}"), sym]
          end
        end
      end
    end
  end
end
