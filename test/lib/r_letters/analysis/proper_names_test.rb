# frozen_string_literal: true

require 'test_helper'

module RLetters
  module Analysis
    class ProperNamesTest < ActiveSupport::TestCase
      test 'works' do
        called_sub100 = false
        called100 = false

        refs = RLetters::Analysis::ProperNames.call(
          dataset: create(:full_dataset),
          progress: lambda do |p|
            if p < 100
              called_sub100 = true
            else
              called100 = true
            end
          end
        )

        refute_empty refs

        assert called_sub100
        assert called100
      end
    end
  end
end
