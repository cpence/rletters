# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    module Collocation
      # Analyze collocations using T tests as the significance measure
      class TTest < Base
        private

        # A method to compute the score for this pair on the basis of the
        # individual and joint frequencies.
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
        # @api private
        # @return [Float] the score for this pair
        # @param [Float] f_a the frequency of word A's appearance in blocks
        # @param [Float] f_b the frequency of word B's appearance in blocks
        # @param [Float] f_ab the frequency of joint appearance of A and B in
        #   blocks
        # @param [Float] n the number of blocks
        def score(f_a, f_b, f_ab, n)
          h_0 = (f_a / n) * (f_b / n)
          t = ((f_ab / n) - h_0) / Math.sqrt((h_0 * (1.0 - h_0)) / n)
          p = 1.0 - Distribution::T.cdf(t, n - 1)

          p
        end

        # Sort results by the score
        #
        # Small p-values indicate more significant grams.
        #
        # @api private
        # @param [Array<Array<(String, Float)>>] grams grams in unsorted order
        # @return [Array<Array<(String, Float)>>] grams in sorted order
        def sort_results(grams)
          grams.sort { |a, b| a[1] <=> b[1] }
        end
      end
    end
  end
end
