# frozen_string_literal: true

require 'test_helper'
require_relative './common_tests'

module RLetters
  module Documents
    module Serializers
      class MarcJsonTest < ActiveSupport::TestCase
        include CommonTests

        test 'single serialization makes no array' do
          doc = build(:full_document)
          json = RLetters::Documents::Serializers::MarcJson.new(doc).serialize

          parsed = JSON.parse(json)

          assert_kind_of Hash, parsed
        end

        test 'array serialization creates the right sized arrays' do
          doc = build(:full_document)
          docs = [doc, doc]
          json = RLetters::Documents::Serializers::MarcJson.new(docs).serialize

          parsed = JSON.parse(json)

          assert_kind_of Array, parsed
          assert_equal 2, parsed.size
        end
      end
    end
  end
end
