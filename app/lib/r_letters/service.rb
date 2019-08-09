# frozen_string_literal: true

module RLetters
  # A module which, when included, adds a class `call` method, to give us a
  # standard API for all our services.
  module Service
    extend ActiveSupport::Concern

    included do
      def self.call(*args)
        new(*args).call
      end
    end
  end
end
