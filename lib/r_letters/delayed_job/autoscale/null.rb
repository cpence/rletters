# frozen_string_literal: true

module RLetters
  module DelayedJob
    module Autoscale
      # An autoscale adapter that does nothing, for when the user is to manage
      # their own workers.
      class Null
        # Returns zero.
        #
        # @return [Integer] 0
        def num_workers
          0
        end

        # Does not do anything.
        #
        # @return [void]
        def scale_up; end

        # Does not do anything.
        #
        # @return [void]
        def scale_down; end
      end
    end
  end
end
