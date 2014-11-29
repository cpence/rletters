# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    module Cooccurrence
      # Analyze coocurrences using mutual information as the significance
      # measure
      class MutualInformation < Base
        # Perform mutual information analysis
        #
        # The formula for the mutual information present in a given
        # cooccurrence pair is:
        #
        # ```
        # PMI(a, b) = log [ (f(a ^ b) * N) / (f(a) * f(b)) ]
        # (with N the number of blocks, f(a) the number of blocks containing a)
        # ```
        #
        # @api public
        # @return [Array<Array(String, Float)>] a set of words and their
        #   associated significance values, sorted in order of significance
        #   (most significant first)
        # @example Run a log-likelihood analysis of a dataset
        #   an = RLetters::Analysis::Cooccurrence::MutualInformation.new(
        #     d, 30, 'evolutionary')
        #   result = an.call
        def call
          base_frequencies, joint_frequencies, n = get_frequencies
          total = base_frequencies.size

          n = n.to_f
          f_a = base_frequencies[@word].to_f

          ret = base_frequencies.each_with_index.map { |(word_2, f_b), i|
            @progress && @progress.call((i.to_f / total.to_f * 33.0).to_i + 66)
            next if word_2 == @word

            f_ab = joint_frequencies[word_2].to_f

            l = (f_ab * n) / (f_a * f_b.to_f)
            l = Math.log(l) unless l.abs < 0.001

            [@word + ' ' + word_2, l]
          }.compact.sort { |a, b| b[1] <=> a[1] }.take(@num_pairs)

          @progress && @progress.call(100)

          ret
        end
      end
    end
  end
end
