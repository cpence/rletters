require 'test_helper'

class EndNoteTest < ActiveSupport::TestCase
  test 'class methods work' do
    assert_kind_of String, RLetters::Documents::Serializers::EndNote.format
    assert_kind_of String, RLetters::Documents::Serializers::EndNote.url
  end

  test 'single document serialization' do
    doc = build(:full_document)
    str = RLetters::Documents::Serializers::EndNote.new(doc).serialize

    assert str.start_with?("%0 Journal Article\n")
    assert_includes str, '%A Dickens, C.'
    assert_includes str, '%T A Tale of Two Cities'
    assert_includes str, '%J Actually a Novel'
    assert_includes str, '%V 1'
    assert_includes str, '%N 1'
    assert_includes str, '%P 1'
    assert_includes str, '%M 10.5678/dickens'
    assert_includes str, '%D 1859'
    # This extra carriage return is the item separator, and is thus very
    # important
    assert str.end_with?("\n\n")
  end

  test 'array serialization' do
    doc = build(:full_document)
    docs = [doc, doc]
    str = RLetters::Documents::Serializers::EndNote.new(docs).serialize

    assert str.start_with?("%0 Journal Article\n")
    assert_includes str, "\n\n%0 Journal Article\n"
  end
end
