
module Admin
  # A benchmark timing how long it takes to run a given job
  #
  # @!attribute job
  #   @return [String] the job class this benchmark is timing
  # @!attribute size
  #   @return [Integer] the size of dataset for this benchmark
  # @!attribute time
  #   @return [Float] the number of seconds this job took to execute on the
  #     given size dataset
  class Benchmark < ActiveRecord::Base
    self.table_name = 'admin_benchmarks'
  end
end
