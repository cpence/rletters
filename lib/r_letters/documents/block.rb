# frozen_string_literal: true

module RLetters
  module Documents
    # A text block resulting from dataset segmentation
    #
    # @!attribute words
    #   @return [Array<String>] The list of words in this block
    # @!attribute name
    #   @return [String] A user-friendly name for this block
    class Block
      include Virtus.model(strict: true, required: false)

      # Sometimes this array is overridden and filled with other things by some
      # of the analysis methods. Don't check/coerce the types.
      attribute :words, Array[String], coerce: false
      attribute :name, String
    end
  end
end
