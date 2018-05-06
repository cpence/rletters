# frozen_string_literal: true
require 'test_helper'
require_relative './common_tests'

class RLetters::Documents::Serializers::MARCJSONTest < ActiveSupport::TestCase
  include RLetters::Documents::Serializers::CommonTests

  test 'array serialization creates the right sized arrays' do
    doc = build(:full_document)
    docs = [doc, doc]
    json = RLetters::Documents::Serializers::MARCJSON.new(docs).serialize

    parsed = JSON.parse(json)

    assert_kind_of Array, parsed
    assert_equal 2, parsed.size
  end
end
