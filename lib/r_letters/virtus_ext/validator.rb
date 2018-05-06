# frozen_string_literal: true

module RLetters
  module VirtusExt
    # A module which, when included, calls a `validate!` method after the
    # `initialize` method finishes.
    module Validator
      extend ActiveSupport::Concern

      # Code to be prepended to a Virtus model's initialization
      module Initializer
        # Initialize a Virtus model
        #
        # This function calls the `validate!` method after the model is
        # constructed.
        #
        # @return [undefined]
        def initialize(attributes = nil)
          super(attributes)
          validate!
        end
      end

      included do
        prepend Initializer
      end
    end
  end
end
