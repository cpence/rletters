require 'test_helper'

class DocumentEnumeratorTest < ActiveSupport::TestCase
  test 'with no custom fields, enumerates documents' do
    enum = RLetters::Datasets::DocumentEnumerator.new(dataset: create(:full_dataset, num_docs: 2))

    assert_includes WORKING_UIDS, enum.first.uid
  end

  test 'with no custom fields, includes no full text or term vectors' do
    enum = RLetters::Datasets::DocumentEnumerator.new(dataset: create(:full_dataset, num_docs: 2))

    assert_nil enum.first.term_vectors
    assert_nil enum.first.fulltext
  end

  test 'with no custom fields, throws if Solr fails' do
    enum = RLetters::Datasets::DocumentEnumerator.new(dataset: create(:full_dataset, num_docs: 2))
    stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout

    assert_raises(RLetters::Solr::ConnectionError) do
      enum.each { |_| }
    end
  end

  test 'with term vectors, it returns term vectors but not full text' do
    enum = RLetters::Datasets::DocumentEnumerator.new(dataset: create(:full_dataset, num_docs: 2),
                                                      term_vectors: true)

    refute_nil enum.first.term_vectors
    assert_nil enum.first.fulltext
  end

  test 'with fulltext, it returns fulltext but not term vectors' do
    enum = RLetters::Datasets::DocumentEnumerator.new(dataset: create(:full_dataset, num_docs: 2),
                                                      fulltext: true)

    refute_nil enum.first.fulltext
    assert_nil enum.first.term_vectors
  end

  test 'with custom fields, it only includes those' do
    enum = RLetters::Datasets::DocumentEnumerator.new(dataset: create(:full_dataset, num_docs: 2),
                                                      fl: 'year')

    assert_nil enum.first.title
    refute_nil enum.first.year
  end
end
