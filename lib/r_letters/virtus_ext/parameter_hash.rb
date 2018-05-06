# frozen_string_literal: true

module RLetters
  module VirtusExt
    # A module which, when included, overrides Virtus's default constructor to
    # keep around the full hash of parameters passed into the constructor.
    #
    # This helps with dependency injection, allowing a constructor to receive
    # parameters that it doesn't know about, which will later be consumed by the
    # constructors of sub-classes.
    module ParameterHash
      extend ActiveSupport::Concern

      # Code to be prepended to a Virtus model's initialization
      module Initializer
        # Initialize a Virtus model
        #
        # This function saves the passed attributes hash as an instance variable
        # and then calls Virtus's own constructor.
        #
        # @return [undefined]
        def initialize(attributes = nil)
          @parameter_hash = attributes || {}
          super(attributes)
        end
      end

      included do
        prepend Initializer

        # Get the hash of parameters passed into the constructor
        #
        # @return [Hash] The set of parameters which constructed this object
        def parameter_hash # rubocop:disable TrivialAccessors
          @parameter_hash
        end
      end
    end
  end
end
