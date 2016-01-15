
module Admin
  # Decorate Benchmark objects
  class BenchmarkDecorator < ApplicationRecordDecorator
    decorates Admin::Benchmark
    delegate_all
  end
end
