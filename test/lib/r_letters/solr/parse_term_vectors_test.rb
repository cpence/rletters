require 'test_helper'

class ParseTermVectorsTest < ActiveSupport::TestCase
  test 'term vector parsing works for good vectors' do
    solr_result = build(:solr_response).response
    array = solr_result['termVectors']

    parser = RLetters::Solr::ParseTermVectors.new(array)
    result = parser.for_document('doi:10.5678/dickens')

    doc = build(:full_document)
    assert_equal doc.term_vectors.deep_stringify_keys, result.deep_stringify_keys

    assert_equal({}, parser.for_document('nope'))
  end

  test 'term vector hashing returns an empty hash for no vectors' do
    empty_array = [
      'uniqueKeyFieldName', 'uid',
      'nope', ['uniqueKey', 'nope', 'fulltext', []]
    ]

    parser = RLetters::Solr::ParseTermVectors.new(empty_array)

    assert_equal({}, parser.for_document('nope'))
  end
end
