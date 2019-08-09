# frozen_string_literal: true

module RLetters
  module Analysis
    # Various analyzers for word collocations
    #
    # Collocations are pairs of words with particular significance or
    # meaning in language.  Linguists use them to point out particular
    # features of a language -- for example, speakers of English use the
    # phrase "strong tea" but would never say "strong computers", preferring
    # instead "powerful computers" (but never "powerful tea").
    module Collocation
      # Syntactic sugar for calling the appropriate analyzer
      #
      # @return [RLetters::Analysis::Collocation::Result] analysis results
      def self.call(*args)
        analyzer = Base.new(*args)

        # Part of speech tagging is a separate analyzer class
        if analyzer.scoring == :parts_of_speech
          analyzer = PartsOfSpeech.new(*args)
        end

        analyzer.call
      end
    end
  end
end
