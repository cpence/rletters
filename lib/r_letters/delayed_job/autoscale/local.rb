# frozen_string_literal: true

module RLetters
  module DelayedJob
    module Autoscale
      # An autoscale adapter that manages processes on the local machine.
      #
      # This class will automatically spin up and down local work processes
      # when needed.
      class Local
        # @return [Integer] the number of processes currently running
        def num_workers
          count = 0

          out = `pgrep -a ruby`
          out.each_line do |line|
            count += 1 if line =~ /rletters:jobs:analysis/
          end

          count
        end

        # Creates a new work process
        #
        # @return [void]
        def scale_up
          rails_bin = Rails.root.join('bin', 'rails').to_s

          pid = spawn(rails_bin, 'rletters:jobs:analysis')
          Process.detach(pid)
        end

        # Signals to a currently running work process to terminate.
        #
        # Note that we just choose the first available and signal for it to
        # stop -- there will be no guarantee for how long that will take.
        #
        # @return [void]
        def scale_down
          out = `pgrep -a ruby`
          out.each_line do |line|
            if line =~ /rletters:jobs:analysis/
              pid = line.split[0].to_i
              Process.kill(:SIGTERM, pid)
            end
          end
        end
      end
    end
  end
end
