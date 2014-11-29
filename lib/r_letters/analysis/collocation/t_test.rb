# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    module Collocation
      # Analyze collocations using T tests as the significance measure
      class TTest < Base
        # Perform T-test analysis
        #
        # To turn frequencies and counts into p values:
        #
        # ```
        # Pr(a) = f(a) / N
        # Pr(b) = f(b) / N
        # H0 = independent occurrences A and B = Pr(a) * Pr(b)
        # x = f(a b) / N
        # s^2 = H0 * (1 - H0)
        # t = (x - H0) / sqrt(s^2 / N)
        # p = 1 - Distribution::T.cdf(t, N-1)
        # ```
        #
        # @api public
        # @return [Array<Array(String, Float)>] a set of words and their
        #   associated significance values, sorted in order of significance
        #   (most significant first)
        # @example Run a t-test analysis of a dataset
        #   an = RLetters::Analysis::Collocation::TTest.new(d, 30)
        #   result = an.call
        def call
          analyzers = get_analyzers

          word_f = analyzers[0].blocks[0]
          bigram_f = analyzers[1].blocks[0]
          total = bigram_f.size

          n = analyzers[0].num_dataset_tokens

          ret = bigram_f.each_with_index.map { |b, i|
            @progress && @progress.call((i.to_f / total.to_f * 33.0).to_i + 66)

            bigram_words = b[0].split
            h_0 = (word_f[bigram_words[0]].to_f / n) *
                  (word_f[bigram_words[1]].to_f / n)
            t = ((b[1].to_f / n) - h_0) / Math.sqrt((h_0 * (1.0 - h_0)) / n)
            p = 1.0 - Distribution::T.cdf(t, n - 1)

            [b[0], p]
          }.sort { |a, b| a[1] <=> b[1] }.take(@num_pairs)

          @progress && @progress.call(100)

          ret
        end
      end
    end
  end
end
