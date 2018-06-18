# frozen_string_literal: true

module RLetters
  module Analysis
    # Code for analyzing the frequency of words occurring in documents
    #
    # To provide inputs to many of the other analysis systems in RLetters,
    # the generation of parallel word frequency lists can be highly tweaked
    # and customized.
    module Frequency
      # Syntactic sugar for calling Base.call
      #
      # @return [RLetters::Analysis::Frequency::Base] analyzer class
      def self.call(*args)
        Base.call(*args)
      end
    end
  end
end
