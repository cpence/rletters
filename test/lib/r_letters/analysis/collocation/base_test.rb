# frozen_string_literal: true

require 'test_helper'
require_relative './common_tests'

module RLetters
  module Analysis
    module Collocation
      # We also test PartsOfSpeech here, as it's the same suite of common tests
      # called through the same entry point.
      class BaseTest < ActiveSupport::TestCase
        include CommonTests
        run_common_tests(RLetters::Analysis::Collocation,
                         %i[mutual_information t_test log_likelihood
                            parts_of_speech])

        test 'throws an exception when scoring is invalid' do
          assert_raises(ArgumentError) do
            RLetters::Analysis::Collocation.call(scoring: :nope,
                                                 dataset: build(:full_dataset))
          end
        end
      end
    end
  end
end
