
module RLetters
  module Analysis
    # Code for constructing word networks from documents
    module Network
      # A edge in a word network
      #
      # The edges in word networks connect two node IDs, and also have a
      # weight value.
      class Edge
        # @return [String] the first node ID
        attr_accessor :one

        # @return [String] the second node ID
        attr_accessor :two

        # @return [Integer] the weight of this node
        attr_accessor :weight
      end
    end
  end
end
