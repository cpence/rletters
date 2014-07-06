# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    module Collocation
      # Analyze collocations using mutual information as the significance
      # measure
      class MutualInformation < Base
        # Perform mutual information analysis
        #
        # The formula for the mutual information present in a given collocation
        # pair is:
        #
        # ```
        # PMI(a, b) = log [ (f(a b) / N) / (f(a) f(b) / N^2) ]
        # (with N the number of single-word tokens)
        # ```
        #
        # @api public
        # @return [Array<Array(String, Float)>] a set of words and their
        #   associated significance values, sorted in order of significance
        #   (most significant first)
        # @example Run a log-likelihood analysis of a dataset
        #   an = RLetters::Analysis::Collocation::MutualInformation.new(d, 30)
        #   result = an.call
        def call
          analyzers = get_analyzers

          word_f = analyzers[0].blocks[0]
          bigram_f = analyzers[1].blocks[0]
          total = bigram_f.size

          n = analyzers[0].num_dataset_tokens.to_f
          n_2 = n * n

          ret = bigram_f.each_with_index.map { |b, i|
            @progress.call((i.to_f / total.to_f * 33.0).to_i + 66) if @progress

            bigram_words = b[0].split
            l = (b[1].to_f / n) /
                (word_f[bigram_words[0]].to_f * word_f[bigram_words[1]].to_f / n_2)
            l = Math.log(l) unless l.abs < 0.001

            [b[0], l]
          }.sort { |a, b| b[1] <=> a[1] }.take(@num_pairs)

          @progress.call(100) if @progress

          ret
        end
      end
    end
  end
end
