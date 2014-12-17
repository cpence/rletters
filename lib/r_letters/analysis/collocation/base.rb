# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    # Various analyzers for word collocations
    #
    # Collocations are pairs of words with particular significance or
    # meaning in language.  Linguists use them to point out particular
    # features of a language -- for example, speakers of English use the
    # phrase "strong tea" but would never say "strong computers", preferring
    # instead "powerful computers" (but never "powerful tea").
    module Collocation
      # Base methods common to all collocation analyzers
      class Base
        # Create a new collocation analyzer
        #
        # @api public
        # @param [Dataset] dataset the dataset to analyze
        # @param [Integer] num_pairs the number of collocations to return
        # @param [String] focal_word if set, all collocations returned will
        #   include this word
        # @param [Proc] progress If set, a function to call with a percentage
        #   of completion (one Integer parameter)
        def initialize(dataset, num_pairs, focal_word = nil, progress = nil)
          @dataset = dataset
          @num_pairs = num_pairs
          @word = focal_word.mb_chars.downcase.to_s if focal_word
          @progress = progress
        end

        # Perform collocation analysis
        #
        # Don't call this on the base class, but on one of the child classes
        # that implements a pair-scoring method.
        #
        # @api public
        # @return [Array<Array(String, Float)>] a set of words and their
        #   associated significance values, sorted in order of significance
        #   (most significant first)
        # @example Run a log-likelihood analysis of a dataset
        #   an = RLetters::Analysis::Collocation::LogLikelihood.new(d, 30)
        #   result = an.call
        def call
          analyzers = get_analyzers

          word_f = analyzers[0].blocks[0]
          bigram_f = analyzers[1].blocks[0]
          total = bigram_f.size

          n = analyzers[0].num_dataset_tokens.to_f

          ret = bigram_f.each_with_index.map do |b, i|
            @progress && @progress.call((i.to_f / total.to_f * 33.0).to_i + 66)

            bigram_words = b[0].split
            f_ab = b[1].to_f
            f_a = word_f[bigram_words[0]].to_f
            f_b = word_f[bigram_words[1]].to_f

            [b[0], score(f_a, f_b, f_ab, n)]
          end

          ret = sort_results(ret).take(@num_pairs)

          @progress && @progress.call(100)

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
        # @api private
        # @return [Array<RLetters::Analysis::Frequency::Base>] two analyzers,
        #   first one-gram and second bi-gram
        def get_analyzers
          # The onegram analyzer can use TFs
          onegram_analyzer = RLetters::Analysis::Frequency::FromTF.new(
            @dataset,
            ->(p) { @progress && @progress.call((p.to_f / 100.0 * 33.0).to_i) })

          # The bigrams should only include the focal word, if the user has
          # restricted the analysis
          bigram_opts = {}
          bigram_opts[:inclusion_list] = @word if @word

          wl = RLetters::Documents::WordList.new(ngrams: 2)
          ds = RLetters::Documents::Segments.new(wl, num_blocks: 1)
          ss = RLetters::Datasets::Segments.new(@dataset, ds, split_across: true)
          bigram_analyzer = RLetters::Analysis::Frequency::FromPosition.new(
            ss,
            ->(p) { @progress && @progress.call((p.to_f / 100.0 * 33.0).to_i + 33) },
            bigram_opts)

          [onegram_analyzer, bigram_analyzer]
        end

        # A method to compute the score for this pair on the basis of the
        # individual and joint frequencies.
        #
        # Not implemented in the base class.
        #
        # @api private
        # @return [Float] the score for this pair
        # @param [Float] f_a the frequency of word A's appearance in blocks
        # @param [Float] f_b the frequency of word B's appearance in blocks
        # @param [Float] f_ab the frequency of joint appearance of A and B in
        #   blocks
        # @param [Float] n the number of blocks
        def score(f_a, f_b, f_ab, n)
          fail NotImplementedError
        end

        # Sort results by the score
        #
        # Not implemented in the base class.
        #
        # @api private
        # @param [Array<Array<(String, Float)>>] grams grams in unsorted order
        # @return [Array<Array<(String, Float)>>] grams in sorted order
        def sort_results(grams)
          fail NotImplementedError
        end
      end
    end
  end
end
