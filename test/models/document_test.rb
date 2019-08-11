# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Import ActiveModel's own test cases
  def setup
    @model = Document.new
  end
  include ActiveModel::Lint::Tests

  test 'should be invalid with no uid' do
    doc = build(:document, uid: nil)

    refute doc.valid?
  end

  test 'should be valid with uid' do
    doc = build(:document)

    assert doc.valid?
  end

  test 'should create GlobalIDs' do
    doc = Document.find('doi:10.1371/journal.pntd.0000534')

    expected = GlobalID.new('gid://r-letters/Document/doi%3A10.1371%2Fjournal.pntd.0000534')
    assert_equal expected, doc.to_global_id
  end

  test 'should look up from GlobalID' do
    doc = Document.find('doi:10.1371/journal.pntd.0000534')
    doc2 = GlobalID::Locator.locate 'gid://r-letters/Document/doi%3A10.1371%2Fjournal.pntd.0000534'

    assert_equal doc.uid, doc2.uid
    assert_equal doc.title, doc2.title
  end

  test 'should find a single document' do
    refute_nil Document.find('doi:10.1371/journal.pntd.0000534')
  end

  test 'find should raise when missing document' do
    assert_raises(ActiveRecord::RecordNotFound) do
      Document.find('fail')
    end
  end

  test 'find should raise when Solr times out' do
    stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
    assert_raises(RLetters::Solr::Connection::Error) do
      Document.find('fail')
    end
  end

  test 'find_by should work with one document' do
    refute_nil Document.find_by(uid: 'doi:10.1371/journal.pntd.0000534')
  end

  test 'find_by should return nil for no documents' do
    assert_nil Document.find_by(uid: 'fail')
  end

  test 'find_by should work with other fields' do
    refute_nil Document.find_by(authors: 'Alan Fenwick')
  end

  test 'find_by! should raise for no documents' do
    assert_raises(ActiveRecord::RecordNotFound) do
      Document.find_by!(uid: 'fail')
    end
  end

  test 'find_by! should raise when Solr times out' do
    stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
    assert_raises(RLetters::Solr::Connection::Error) do
      Document.find_by!(uid: 'fail')
    end
  end

  test 'should load uid for single document' do
    assert_equal 'doi:10.1371/journal.pntd.0000534', Document.find('doi:10.1371/journal.pntd.0000534').uid
  end

  test 'should not load term vectors for single document' do
    assert_nil Document.find('doi:10.1371/journal.pntd.0000534').term_vectors
  end

  test 'should get attributes for a set of documents' do
    docs = RLetters::Solr::Connection.search(q: '*:*', def_type: 'lucene').documents

    assert_equal 'doi:10.5678/dickens', docs[0].uid
    assert_equal '10.1371/journal.pntd.0000032', docs[3].doi
    assert_equal 'Public domain', docs[0].license
    assert_equal 'http://creativecommons.org/licenses/by/3.0/', docs[2].license_url
    assert_equal 'Development of Highly Organized Lymphoid Structures in Buruli Ulcer Lesions after Treatment with Rifampicin and Streptomycin', docs[2].title
    assert_equal 'Actually a Novel', docs[0].journal
    assert_equal '2007', docs[5].year
    assert_equal '1', docs[7].volume
    assert_equal 'e64', docs[8].pages

    authors = ['Luis Fernando Chaves', 'Mercedes Pascual']
    assert_equal authors, docs[4].authors.map(&:full).sort
  end

  test 'should nil out empty attributes' do
    doc = build(:document, volume: '')

    assert_nil doc.volume
  end

  test 'should nil out blank attributes' do
    doc = build(:document, number: '   ')

    assert_nil doc.number
  end

  test 'should parse basic start and end pages' do
    doc = build(:document, pages: '1227-1238')

    assert_equal '1227', doc.start_page
    assert_equal '1238', doc.end_page
  end

  test 'should parse abbreviated start and end pages' do
    doc = build(:document, pages: '1483-92')

    assert_equal '1483', doc.start_page
    assert_equal '1492', doc.end_page
  end

  test 'should parse non-ranged start and end pages' do
    doc = build(:document, pages: 'e1234')

    assert_equal 'e1234', doc.start_page
    assert_nil doc.end_page
  end

  test 'should parse term vectors correctly' do
    doc = Document.find('doi:10.1371/journal.pntd.0000534', term_vectors: true)

    refute_nil doc.term_vectors

    assert_equal 2, doc.term_vectors['decrease'][:tf]
    assert_equal 21, doc.term_vectors['hyperendemic'][:positions][0]
    assert_equal 389, doc.term_vectors['population'][:df]
    assert_nil doc.term_vectors['zuzax']
  end
end
