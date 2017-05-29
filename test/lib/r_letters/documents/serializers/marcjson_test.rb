require 'test_helper'
require_relative './serializer_tests'

class MARCJSONTest < ActiveSupport::TestCase
  include SerializerTests

  test 'array serialization creates the right sized arrays' do
    doc = build(:full_document)
    docs = [doc, doc]
    json = RLetters::Documents::Serializers::MARCJSON.new(docs).serialize

    parsed = JSON.load(json)

    assert_kind_of Array, parsed
    assert_equal 2, parsed.size
  end
end
