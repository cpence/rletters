# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    module Collocation
      class TTest < Base
        def call
          # T-TEST
          # Pr(a) = f(a) / N
          # Pr(b) = f(b) / N
          # H0 = independent occurrences A and B = Pr(a) * Pr(b)
          # x = f(a b) / N
          # s^2 = H0 * (1 - H0)
          # t = (x - H0) / sqrt(s^2 / N)
          # convert t to a p-value based on N
          #   1 - Distribution::T.cdf(t, N-1)
          analyzers = get_analyzers

          word_f = analyzers[0].blocks[0]
          bigram_f = analyzers[1].blocks[0]
          total = bigram_f.size

          n = analyzers[0].num_dataset_tokens

          ret = bigram_f.each_with_index.map { |b, i|
            @progress.call((i.to_f / total.to_f * 33.0).to_i + 66) if @progress

            bigram_words = b[0].split
            h_0 = (word_f[bigram_words[0]].to_f / n) *
                  (word_f[bigram_words[1]].to_f / n)
            t = ((b[1].to_f / n) - h_0) / Math.sqrt((h_0 * (1.0 - h_0)) / n)
            p = 1.0 - Distribution::T.cdf(t, n - 1)

            [b[0], p]
          }.sort { |a, b| a[1] <=> b[1] }.take(@num_pairs)

          @progress.call(100) if @progress

          ret
        end
      end
    end
  end
end
