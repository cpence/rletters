# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    module Collocation
      class LogLikelihood < Base
        def call
          # LIKELIHOOD RATIO
          # Log-lambda = log L(f(a b), f(a), f(a) / N) +
          #              log L(f(b) - f(a b), N - f(a), f(a) / N) -
          #              log L(f(a b), f(a), f(a b) / f(a)) -
          #              log L(f(b) - f(a b), N - f(a), (f(b) - f(a b)) / (N - f(a)))
          # sort by -2 log-lambda
          analyzers = get_analyzers

          word_f = analyzers[0].blocks[0]
          bigram_f = analyzers[1].blocks[0]
          total = bigram_f.size

          n = analyzers[0].num_dataset_tokens.to_f

          ret = bigram_f.each_with_index.map { |b, i|
            @progress.call((i.to_f / total.to_f * 33.0).to_i + 66) if @progress

            bigram_words = b[0].split
            f_ab = b[1].to_f
            f_a = word_f[bigram_words[0]].to_f
            f_b = word_f[bigram_words[1]].to_f

            ll = log_l(f_ab, f_a, f_a / n) +
                 log_l(f_b - f_ab, n - f_a, f_a / n) -
                 log_l(f_ab, f_a, f_ab / f_a) -
                 log_l(f_b - f_ab, n - f_a, (f_b - f_ab) / (n - f_a))
            [b[0], -2.0 * ll]
          }.sort { |a, b| b[1] <=> a[1] }.take(@num_pairs)

          @progress.call(100) if @progress

          ret
        end

        private

        def log_l(k, n, x)
          # L(k, n, x) = x^k (1 - x)^(n - k)
          l = x**k * ((1 - x)**(n - k))
          l = Math.log(l) unless l.abs < 0.001
          l
        end
      end
    end
  end
end
