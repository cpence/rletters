# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    module Collocation
      class MutualInformation < Base
        def call
          # MUTUAL INFORMATION
          # PMI(a, b) = log [ (f(a b) / N) / (f(a) f(b) / N^2) ]
          # with N the number of single-word tokens
          analyzers = get_analyzers

          word_f = analyzers[0].blocks[0]
          bigram_f = analyzers[1].blocks[0]
          total = bigram_f.size

          n = analyzers[0].num_dataset_tokens.to_f
          n_2 = n * n

          bigram_f.each_with_index.map { |b, i|
            @progress.call((i.to_f / total.to_f * 33.0).to_i + 66) if @progress

            bigram_words = b[0].split
            l = (b[1].to_f / n) /
                (word_f[bigram_words[0]].to_f * word_f[bigram_words[1]].to_f / n_2)
            l = Math.log(l) unless l.abs < 0.001

            [b[0], l]
          }.sort { |a, b| b[1] <=> a[1] }
        end
      end
    end
  end
end
