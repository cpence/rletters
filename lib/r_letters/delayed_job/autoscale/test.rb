# frozen_string_literal: true

module RLetters
  module DelayedJob
    module Autoscale
      # An autoscale adapter that just records how many times scale_up/down has
      # been called, for testing purposes.
      class Test
        # Create the test scaling adapter
        def initialize
          @num_workers = 0
        end

        # Returns the number of workers that would be running given scaling
        # requests.
        #
        # @return [Integer] number of workers
        def num_workers
          @num_workers
        end

        # Increase number of workers by one.
        #
        # @return [void]
        def scale_up
          @num_workers += 1
        end

        # Decrease number of workers by one.
        #
        # @return [void]
        def scale_down
          @num_workers -= 1
        end
      end
    end
  end
end
