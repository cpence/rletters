
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
  class Benchmark < ApplicationRecord
    self.table_name = 'admin_benchmarks'

    # @return (see ApplicationRecord.admin_attributes)
    def self.admin_attributes
      {
        job: { form_options: { disabled: true } },
        size: { form_options: { disabled: true } },
        time: {}
      }
    end

    # @return (see ApplicationRecord.admin_configuration)
    def self.admin_configuration
      { no_create: true, no_delete: true }
    end
  end
end
