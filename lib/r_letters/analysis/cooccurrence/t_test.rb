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
          analyzer = get_analyzer
          blocks = analyzer.blocks
          total = analyzer.blocks[0].size

          n = blocks.size.to_f
          f_a = blocks.count { |b| b[@word].to_i != 0 }

          # Notably, if the requested word doesn't appear anywhere at all, we
          # should just quit while we're ahead
          if f_a == 0
            @progress.call(100) if @progress

            return []
          end

          ret = blocks[0].each_with_index.map { |(word_2, count), i|
            @progress.call((i.to_f / total.to_f * 50.0).to_i + 50) if @progress
            next if word_2 == @word

            f_b = blocks.count { |b| b[word_2].to_i != 0 }
            f_ab = blocks.count { |b| b[@word].to_i != 0 &&
                                      b[word_2].to_i != 0 }

            h_0 = (f_a.to_f / n) * (f_b.to_f / n)
            t = ((f_ab.to_f / n) - h_0) / Math.sqrt((h_0 * (1.0 - h_0)) / n)
            p = 1.0 - Distribution::T.cdf(t, n - 1)

            [@word + ' ' + word_2, p]
          }.sort { |a, b| a[1] <=> b[1] }.take(@num_pairs)

          @progress.call(100) if @progress

          ret
        end
      end
    end
  end
end
