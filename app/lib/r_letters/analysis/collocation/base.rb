# frozen_string_literal: true

module RLetters
  module Analysis
    module Collocation
      # Base methods common to all collocation analyzers
      #
      # @!attribute dataset
      #   @return [Dataset] the dataset to analyze
      # @!attribute num_pairs
      #   @return [Integer] the number of cooccurrences to return
      # @!attribute all
      #   @return [Boolean] if set to true, return all pairs
      # @!attribute scoring
      #   @return [Symbol] the scoring method to use. Can be `:log_likelihood`,
      #     `:mutual_information`, `:t_test`, or `:parts_of_speech`.
      # @!attribute focal_word
      #   @return [String] if set, all collocations returned will
      #     include this word
      # @!attribute progress
      #   @return [Proc] if set, a function to call with percentage of
      #     completion (one integer parameter)
      class Base
        include Service
        include Virtus.model(strict: true, required: false,
                             nullify_blank: true)

        attribute :dataset, Dataset, required: true
        attribute :scoring, Symbol, required: true
        attribute :num_pairs, Integer, default: 0
        attribute :all, Boolean, default: false
        attribute :focal_word, VirtusExt::LowercaseString
        attribute :progress, Proc

        # Perform collocation analysis
        #
        # @return [RLetters::Analysis::Collocation::Result] analysis results
        def call
          case scoring
          when :log_likelihood
            score_class = Scoring::LogLikelihood
          when :mutual_information
            score_class = Scoring::MutualInformation
          when :t_test
            score_class = Scoring::TTest
          else
            raise ArgumentError, "cannot score collocations with #{scoring}"
          end

          # Ignore num_pairs if we want all of the cooccurrences
          self.num_pairs = nil if all || num_pairs&.<=(0)

          an = analyzers

          word_f = an[0].blocks[0]
          bigram_f = an[1].blocks[0]
          total = bigram_f.size

          n = an[0].num_dataset_tokens.to_f

          ret = Result.new(scoring: scoring, collocations: [])

          ret.collocations = bigram_f.each_with_index.map do |b, i|
            progress&.call((i.to_f / total.to_f * 33.0).to_i + 66)

            bigram_words = b[0].split
            f_ab = b[1].to_f
            f_a = word_f[bigram_words[0]].to_f
            f_b = word_f[bigram_words[1]].to_f

            [b[0], score_class.score(f_a, f_b, f_ab, n)]
          end

          score_class.sort_results!(ret.collocations)
          ret.collocations = ret.collocations.take(num_pairs) if num_pairs

          progress&.call(100)
          ret
        end

        protected

        # Return two analyzers for doing collocation analysis
        #
        # Many of the analysis methods here need two analyzers -- one that will
        # analyze one-grams, and one that will analyze bigrams, so that we can
        # use frequency information from each for comparison.  This function
        # builds those two analyzers.
        #
        # @return [Array<RLetters::Analysis::Frequency::Base>] two analyzers,
        #   first one-gram and second bi-gram
        def analyzers
          onegram_analyzer = Frequency.call(
            dataset: dataset,
            progress: ->(p) { progress&.call((p.to_f / 100 * 33).to_i) }
          )

          # The bigrams should only include the focal word, if the user has
          # restricted the analysis
          bigram_analyzer = Frequency.call(
            dataset: dataset,
            ngrams: 2,
            inclusion_list: focal_word,
            num_blocks: 1,
            split_across: true,
            progress: ->(p) { progress&.call((p.to_f / 100 * 33).to_i + 33) }
          )

          [onegram_analyzer, bigram_analyzer]
        end
      end
    end
  end
end
