# frozen_string_literal: true

module RLetters
  module Analysis
    # Code for constructing word networks from documents
    module Network
      # A edge in a word network
      #
      # The edges in word networks connect two node IDs, and also have a
      # weight value.
      #
      # @!attribute one
      #   @return [String] the first node ID
      # @!attribute two
      #   @return [String] the second node ID
      # @!attribute weight
      #   @return [Integer] the weight of this node
      class Edge
        include Virtus.model(strict: true, required: true, nullify_blank: true)

        attribute :one, String
        attribute :two, String
        attribute :weight, Integer
      end
    end
  end
end
