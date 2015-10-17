module RLetters
  module Documents
    # A text block resulting from dataset segmentation
    class Block
      # @return [Array<String>] The list of words in this block
      attr_accessor :words

      # @return [String] A user-friendly name for this block
      attr_accessor :name

      # Create a new block
      #
      # @param [Array<String>] words The list of words in this block
      # @param [String] name A user-friendly name for this block
      # @return [Block] A new block object
      def initialize(words, name)
        self.words = words
        self.name = name
      end
    end
  end
end
