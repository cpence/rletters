
module RLetters
  module Analysis
    module Scoring
      # Compute scores on the basis of T tests
      module TTest
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
        # @return [Float] the score for this pair
        # @param [Float] f_a the frequency of word A's appearance in blocks
        # @param [Float] f_b the frequency of word B's appearance in blocks
        # @param [Float] f_ab the frequency of joint appearance of A and B in
        #   blocks
        # @param [Float] n the number of blocks
        def self.score(f_a, f_b, f_ab, n)
          h_0 = (f_a / n) * (f_b / n)
          denom = Math.sqrt((h_0 * (1.0 - h_0)) / n)

          # Hard to know the right answer here, but we certainly shouldn't
          # divide by zero
          denom = 0.001 if denom.abs < 0.001

          t = ((f_ab / n) - h_0) / denom
          p = 1.0 - Distribution::T.cdf(t, n - 1)

          p
        end

        # Sort results by the score
        #
        # Small p-values indicate more significant grams.
        #
        # @param [Array<Array<(String, Float)>>] grams grams in unsorted order
        # @return [Array<Array<(String, Float)>>] grams in sorted order
        def self.sort_results(grams)
          grams.sort { |a, b| a[1] <=> b[1] }
        end
      end
    end
  end
end
