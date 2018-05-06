# frozen_string_literal: true

module RLetters
  module Analysis
    module Collocation
      # The results of a collocation analysis
      #
      # @!attribute collocations
      #   @return [Array<Array(String, Float)>] a set of words and their
      #     associated significance values, sorted in order of significance
      #     (most significant first)
      # @!attribute scoring
      #   @return [Symbol] the scoring method actually used. This can be
      #     altered by the analyzer, e.g., when parts of speech analysis is
      #     requested but the Stanford NLP is not available.
      class Result
        include Virtus.model(strict: true, required: true, nullify_blank: true)

        attribute :collocations, Array
        attribute :scoring, Symbol
      end
    end
  end
end
