# frozen_string_literal: true

module RLetters
  module Analysis
    class Cooccurrence
      # A class encapsulating the results from an analysis
      #
      # @!attribute cooccurrences
      #   @return [Array<Array(String, Float)>] a set of words and their
      #     associated significance values, sorted in order of significance
      #     (most significant first)
      # @!attribute scoring
      #   @return [Symbol] the scoring method actually used.
      # @!attribute stemming
      #   @return [Symbol] the stemming method actually used. This can be
      #     altered by the analyzer.
      class Result
        include Virtus.model(strict: true, required: false,
                             nullify_blank: true)

        attribute :cooccurrences, Array
        attribute :scoring, Symbol
        attribute :stemming, Symbol
      end
    end
  end
end
