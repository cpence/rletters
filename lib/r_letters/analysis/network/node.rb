
module RLetters
  module Analysis
    # Code for constructing word networks from documents
    module Network
      # A node in a word network
      #
      # The nodes in word networks have a main identifier (usually a stemmed
      # word form), a list of words at that node, and can appear in graph
      # edges.
      class Node
        # @return [String] the node identifier
        attr_accessor :id

        # @return [Array<String>] all words represented by this node
        attr_accessor :words
      end
    end
  end
end
