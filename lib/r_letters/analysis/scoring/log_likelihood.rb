# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    # Code for scoring associations on the basis of their frequencies
    module Scoring
      # Compute scores on the basis of log likelihood
      module LogLikelihood
        private

        # The L-function required in the log-likelihood calculation
        #
        # @api private
        # @return [Float] the log-likelihood of obtaining the outcome x in
        #   the binomial distribution defined by n and k
        # @param [Integer] k number of successes
        # @param [Integer] n number of trials
        # @param [Float] x the observed outcome
        def log_l(k, n, x)
          # L(k, n, x) = x^k (1 - x)^(n - k)
          l = x**k * ((1 - x)**(n - k))
          l = Math.log(l) unless l.abs < 0.001
          l
        end

        # A method to compute the score for this pair on the basis of the
        # individual and joint frequencies.
        #
        # The formula for the log-likelihood of a collocation pair is:
        #
        # ```
        # L(k, n, x) = x^k (1 - x)^(n - k)
        # Log-lambda = log L(f(a b), f(a), f(a) / N) +
        #              log L(f(b) - f(a b), N - f(a), f(a) / N) -
        #              log L(f(a b), f(a), f(a b) / f(a)) -
        #              log L(f(b) - f(a b), N - f(a),
        #                    (f(b) - f(a b)) / (N - f(a)))
        # sort by -2 log-lambda
        # ```
        #
        # @api private
        # @return [Float] the score for this pair
        # @param [Float] f_a the frequency of word A's appearance in blocks
        # @param [Float] f_b the frequency of word B's appearance in blocks
        # @param [Float] f_ab the frequency of joint appearance of A and B in
        #   blocks
        # @param [Float] n the number of blocks
        def score(f_a, f_b, f_ab, n)
          ll = log_l(f_ab, f_a, f_a / n) +
               log_l(f_b - f_ab, n - f_a, f_a / n) -
               log_l(f_ab, f_a, f_ab / f_a) -
               log_l(f_b - f_ab, n - f_a, (f_b - f_ab) / (n - f_a))

          -2.0 * ll
        end

        # Sort results by the score
        #
        # High log-likelihood results indicate more significant grams.
        #
        # @api private
        # @param [Array<Array<(String, Float)>>] grams grams in unsorted order
        # @return [Array<Array<(String, Float)>>] grams in sorted order
        def sort_results(grams)
          grams.sort { |a, b| b[1] <=> a[1] }
        end
      end
    end
  end
end
