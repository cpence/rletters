# frozen_string_literal: true

module RLetters
  module Analysis
    # Code for constructing word networks from documents
    module Network
      # A node in a word network
      #
      # The nodes in word networks have a main identifier (usually a stemmed
      # word form), a list of words at that node, and can appear in graph
      # edges.
      #
      # @!attribute id
      #   @return [String] the node identifier
      # @!attribute words
      #   @return [Array<String>] all words represented by this node
      class Node
        include Virtus.model(strict: true, required: true, nullify_blank: true)

        attribute :id, String
        attribute :words, Array[String]
      end
    end
  end
end
