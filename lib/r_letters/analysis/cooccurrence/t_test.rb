# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    module Cooccurrence
      # Analyze cooccurrences using T tests as the significance measure
      class TTest < Base
        # Perform T-test analysis
        #
        # To turn frequencies and counts into p values:
        #
        # ```
        # N = number of blocks
        # f(a) = number of blocks containing a
        # Pr(a) = f(a) / N
        # Pr(b) = f(b) / N
        # H0 = independent occurrences A and B = Pr(a) * Pr(b)
        # x = f(a ^ b) / N
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
        #   an = RLetters::Analysis::Cooccurrence::TTest.new(
        #     d, 30, 'evolutionary')
        #   result = an.call
        def call
          base_frequencies, joint_frequencies, n = get_frequencies
          total = base_frequencies.size

          n = n.to_f
          f_a = base_frequencies[@word].to_f

          # Notably, if the requested word doesn't appear anywhere at all, we
          # should just quit while we're ahead
          if f_a == 0
            @progress && @progress.call(100)

            return []
          end

          ret = base_frequencies.each_with_index.map { |(word_2, f_b), i|
            @progress && @progress.call((i.to_f / total.to_f * 33.0).to_i + 66)
            next if word_2 == @word

            f_ab = joint_frequencies[word_2].to_f

            h_0 = (f_a / n) * (f_b.to_f / n)
            t = ((f_ab / n) - h_0) / Math.sqrt((h_0 * (1.0 - h_0)) / n)
            p = 1.0 - Distribution::T.cdf(t, n - 1)

            [@word + ' ' + word_2, p]
          }.compact.sort { |a, b| a[1] <=> b[1] }.take(@num_pairs)

          @progress && @progress.call(100)

          ret
        end
      end
    end
  end
end
