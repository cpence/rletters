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

        # Return frequency counts
        #
        # All cooccurrence analyzers use the same input data -- the frequency
        # of words in bins of the given window size. This function computes
        # that data.
        #
        # Also, putting this in its own function *should* encourage the GC to
        # clean up the analyzer object after this function returns.
        #
        # @api private
        # @return [Array<(Hash<String, Integer>, Hash<String, Integer>, Integer)]
        #   First, the number of bins in which every word in the dataset
        #   appears (the +base_frequencies+). Second, the number of bins in
        #   which every word *and* the word at issue both appear (the
        #   +joint_frequencies+). Lastly, the number of bins (+n+).
        def get_frequencies
          wl = RLetters::Documents::WordList.new
          ds = RLetters::Documents::Segments.new(wl,
                                                 block_size: @window,
                                                 last_block: :small_last)
          ss = RLetters::Datasets::Segments.new(@dataset,
                                                ds,
                                                split_across: false)

          analyzer = RLetters::Analysis::Frequency::FromPosition.new(
            ss,
            ->(p) {
              if @progress
                @progress.call((p.to_f / 100.0 * 50.0).to_i)
              end
            })

          # Combine all the block hashes, summing the values
          base_frequencies = analyzer.blocks.inject(Hash.new(0)) do |ret, b|
            ret.merge(b) do |key, old_val, new_val|
              old_val + (new_val && new_val > 0 ? 1 : 0)
            end
          end

          # Get the frequencies of cooccurrence with the word in question
          joint_frequencies = analyzer.blocks.inject(Hash.new(0)) do |ret, b|
            if b[@word] && b[@word] > 0
              ret.merge(b) do |key, old_val, new_val|
                old_val + (new_val && new_val > 0 ? 1 : 0)
              end
            else
              ret
            end
          end

          # Prune any zero values to make analysis easier later
          base_frequencies.reject! { |k, v| v == 0 }
          joint_frequencies.reject! { |k, v| v == 0 }

          [base_frequencies, joint_frequencies, analyzer.blocks.size]
        end
      end
    end
  end
end
