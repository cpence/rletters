# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    module Collocation
      # Base methods common to all collocation analyzers
      class Base
        def initialize(dataset, num_pairs, focal_word = nil, progress = nil)
          @dataset = dataset
          @num_pairs = num_pairs
          @word = focal_word.mb_chars.downcase.to_s if focal_word
          @progress = progress
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
            ->(p) {
              if @progress
                @progress.call((p.to_f / 100.0 * 33.0).to_i + 33)
              end
            })

          # The bigrams should only include the focal word, if the user has
          # restricted the analysis
          bigram_opts = {}
          bigram_opts[:inclusion_list] = @word if @word

          wl = RLetters::Documents::WordList.new(ngrams: 2)
          ds = RLetters::Documents::Segments.new(wl, num_blocks: 1)
          ss = RLetters::Datasets::Segments.new(@dataset, ds, split_across: true)
          bigram_analyzer = RLetters::Analysis::Frequency::FromPosition.new(
            ss,
            ->(p) {
              if @progress
                @progress.call((p.to_f / 100.0 * 33.0).to_i + 66)
              end
            },
            bigram_opts)

          [onegram_analyzer, bigram_analyzer]
        end
      end
    end
  end
end
