# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    module Cooccurrence
      # Analyze coocurrences using mutual information as the significance
      # measure
      class MutualInformation < Base
        private

        # Compute mutual information score
        #
        # The formula for the mutual information present in a given
        # cooccurrence pair is:
        #
        # ```
        # PMI(a, b) = log [ (f(a ^ b) * N) / (f(a) * f(b)) ]
        # (with N the number of blocks, f(a) the number of blocks containing a)
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
          l = (f_ab * n) / (f_a * f_b)
          l = Math.log(l) unless l.abs < 0.001

          l
        end
      end
    end
  end
end
