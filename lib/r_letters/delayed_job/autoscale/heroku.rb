# frozen_string_literal: true

module RLetters
  module DelayedJob
    module Autoscale
      # An autoscale adapter that provisions and destroys worker dynos on
      # Heroku.
      class Heroku
        # @return [Integer] the number of currently running worker dynos
        def num_workers
          heroku.app.info(ENV['HEROKU_APP_NAME'])['workers']
        end

        # Provisions and launches a new worker dyno.
        #
        # @return [void]
        def scale_up
          heroku.formation.update(ENV['HEROKU_APP_NAME'], 'worker',
                                  { 'quantity' => 1 })
        end

        # Signals to a worker dyno to exit when its jobs are completed.
        #
        # @return [void]
        def scale_down
          heroku.formation.update(ENV['HEROKU_APP_NAME'], 'worker',
                                  { 'quantity' => 0 })
        end

        private

        # Get a heroku client instance with our configured API key.
        #
        # @return [PlatformAPI::Client] a connected client
        def heroku
          @heroku ||= PlatformAPI.connect_oauth(ENV['AUTOSCALE_API_KEY'])
        end
      end
    end
  end
end
