# frozen_string_literal: true

require 'test_helper'
require_relative './common_tests'

module RLetters
  module Documents
    module Serializers
      class MARCJSONTest < ActiveSupport::TestCase
        include CommonTests

        test 'single serialization' do
          doc = build(:full_document)
          marc = RLetters::Documents::Serializers::MARC21.new(doc).serialize

          # We just can't test this nonsense
          assert marc.start_with? '00'
        end
      end
    end
  end
end
