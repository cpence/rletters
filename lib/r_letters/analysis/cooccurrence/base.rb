# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    # Various analyzers for cooccurrence patterns
    #
    # Co-occurrences, as opposed to collocations, are words whose appearance is
    # statistically significantly correlated, but which (unlike collocations)
    # do *not* appear directly adjacent to one another.
    #
    # This analyzer takes a given word and returns all pairs in which that
    # word appears, sorted by significance.
    module Cooccurrence
      # Base methods common to all cooccurrence analyzers
      class Base
        # Create a new cooccurrence analyzer
        #
        # @api public
        # @param [Dataset] dataset the dataset to analyze
        # @param [Integer] num_pairs the number of cooccurrences to return
        # @param [String] word_1 the word that must occur in all pairs
        # @param [Integer] window the window size to use for analysis
        #   The default size of 200 approximates "paragraph-level" cooccurrence
        #   analysis.
        # @param [Proc] progress If set, a function to call with a percentage
        #   of completion (one Integer parameter)
        def initialize(dataset, num_pairs, word, window = 200,
                       progress = nil)
          @dataset = dataset
          @num_pairs = num_pairs
          @word = word.mb_chars.downcase.to_s
          @window = window.to_i
          @progress = progress
        end

        protected

        # Return the analyzer for cooccurrence analysis
        #
        # Since the window is set per-job, all the cooccurrence analyzers use
        # the same frequency analyzer. This function builds it.
        #
        # @api private
        # @return [RLetters::Analysis::Frequency::Base] word frequency analyzer
        def get_analyzer
          wl = RLetters::Documents::WordList.new
          ds = RLetters::Documents::Segments.new(wl,
                                                 block_size: @window,
                                                 last_block: :small_last)
          ss = RLetters::Datasets::Segments.new(@dataset,
                                                ds,
                                                split_across: false)

          RLetters::Analysis::Frequency::FromPosition.new(
            ss,
            ->(p) {
              if @progress
                @progress.call((p.to_f / 100.0 * 50.0).to_i)
              end
            })
        end
      end
    end
  end
end
