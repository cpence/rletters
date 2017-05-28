require 'test_helper'

class MARCJSONTest < ActiveSupport::TestCase
  test 'class methods work' do
    assert_kind_of String, RLetters::Documents::Serializers::MARCJSON.format
    assert_kind_of String, RLetters::Documents::Serializers::MARCJSON.url
  end

  test 'array serialization creates the right sized arrays' do
    doc = build(:full_document)
    docs = [doc, doc]
    json = RLetters::Documents::Serializers::MARCJSON.new(docs).serialize

    parsed = JSON.load(json)

    assert_kind_of Array, parsed
    assert_equal 2, parsed.size
  end
end
