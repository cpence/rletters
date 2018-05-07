# frozen_string_literal: true

require 'test_helper'
require_relative './common_tests'

module RLetters
  module Analysis
    module Collocation
      class BaseTest < ActiveSupport::TestCase
        include CommonTests
        run_common_tests(RLetters::Analysis::Collocation,
                         [:mutual_information, :t_test, :log_likelihood])

        test 'throws an exception when scoring is invalid' do
          assert_raises(ArgumentError) do
            RLetters::Analysis::Collocation.call(scoring: :nope,
                                                 dataset: build(:full_dataset))
          end
        end

        test 'falls back to MI when NLP not available' do
          old_path = ENV['NLP_TOOL_PATH']
          ENV['NLP_TOOL_PATH'] = nil

          result = RLetters::Analysis::Collocation.call(
            scoring: :parts_of_speech,
            dataset: create(:full_dataset),
            num_pairs: 10)
          assert_equal :mutual_information, result.scoring

          ENV['NLP_TOOL_PATH'] = @old_path
        end
      end
    end
  end
end
