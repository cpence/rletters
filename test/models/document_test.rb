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
    assert_raises(RLetters::Solr::ConnectionError) do
      Document.find('fail')
    end
  end

  test 'should find a single document with fulltext' do
    refute_nil Document.find('doi:10.1371/journal.pntd.0000534', fulltext: true)
  end

  test 'find should raise with fulltext when missing document' do
    assert_raises(ActiveRecord::RecordNotFound) do
      Document.find('fail', fulltext: true)
    end
  end

  test 'find should raise with fulltext when Solr times out' do
    stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
    assert_raises(RLetters::Solr::ConnectionError) do
      Document.find('fail', fulltext: true)
    end
  end

  test 'find should work with external fulltext' do
    stub_connection('http://www.gutenberg.org/cache/epub/3172/pg3172.txt', 'gutenberg')
    doc = Document.find('gutenberg:3172', fulltext: true, term_vectors: true)

    refute_nil doc
    assert doc.fulltext.start_with?('The Project Gutenberg EBook of')

    assert_includes doc.fulltext_url.to_s, 'www.gutenberg.org'
    assert_requested :get, 'http://www.gutenberg.org/cache/epub/3172/pg3172.txt'

    refute_nil doc.term_vectors
    assert_equal 44, doc.term_vectors['cooper']['tf']
  end

  test 'find should work with external fulltext with BOM' do
    stub_request(:get, /www\.gutenberg\.org/).to_return(
      body: "\xEF\xBB\xBFStart of Response".dup,
      status: 200,
      headers: { 'Content-Length' => 20 })
    doc = Document.find('gutenberg:3172', fulltext: true, term_vectors: true)

    refute_nil doc
    assert_includes doc.fulltext_url.to_s, 'www.gutenberg.org'
    assert doc.fulltext.start_with?('Start of Response')
  end

  test 'find_by should work with one document, no fulltext' do
    refute_nil Document.find_by(uid: 'doi:10.1371/journal.pntd.0000534')
  end

  test 'find_by should return nil for no documents, no fulltext' do
    assert_nil Document.find_by(uid: 'fail')
  end

  test 'find_by should work with other fields, no fulltext' do
    refute_nil Document.find_by(authors: 'Alan Fenwick')
  end

  test 'find_by should work with one document, fulltext' do
    refute_nil Document.find_by(uid: 'doi:10.1371/journal.pntd.0000534', fulltext: true)
  end

  test 'find_by should return nil for no documents, fulltext' do
    assert_nil Document.find_by(uid: 'fail', fulltext: true)
  end

  test 'find_by! should raise for no documents' do
    assert_raises(ActiveRecord::RecordNotFound) do
      Document.find_by!(uid: 'fail')
    end
  end

  test 'find_by! should raise when Solr times out' do
    stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
    assert_raises(RLetters::Solr::ConnectionError) do
      Document.find_by!(uid: 'fail')
    end
  end

  test 'should load uid for single document' do
    assert_equal 'doi:10.1371/journal.pntd.0000534', Document.find('doi:10.1371/journal.pntd.0000534').uid
  end

  test 'should not load fulltext for single document' do
    assert_nil Document.find('doi:10.1371/journal.pntd.0000534').fulltext
  end

  test 'should not load term vectors for single document' do
    assert_nil Document.find('doi:10.1371/journal.pntd.0000534').term_vectors
  end

  test 'should load uid for single document with fulltext' do
    assert_equal 'doi:10.1371/journal.pntd.0000534', Document.find('doi:10.1371/journal.pntd.0000534', fulltext: true).uid
  end

  test 'should load fulltext for single document with fulltext' do
    refute_nil Document.find('doi:10.1371/journal.pntd.0000534', fulltext: true).fulltext
  end

  test 'should not load term vectors for single document with fulltext' do
    assert_nil Document.find('doi:10.1371/journal.pntd.0000534', fulltext: true).term_vectors
  end

  test 'should get attributes for a set of documents' do
    docs = RLetters::Solr::Connection.search(q: '*:*', def_type: 'lucene').documents

    assert_equal 'doi:10.5678/dickens', docs[0].uid
    assert_equal '10.1371/journal.pntd.0000002', docs[3].doi
    assert_equal 'Public domain', docs[0].license
    assert_equal 'http://creativecommons.org/licenses/by/3.0/', docs[2].license_url
    assert_equal 'Perturbation of the Dimer Interface of Triosephosphate Isomerase and its Effect on Trypanosoma cruzi', docs[2].title
    assert_equal 'Actually a Novel', docs[0].journal
    assert_equal '2007', docs[5].year
    assert_equal '1', docs[7].volume
    assert_equal 'e56', docs[8].pages

    authors = ['Dominique Legros', 'Florence Thomas', 'Francesco Checchi',
               'Gerardo Priotto', 'Harriet Ayikoru', 'Patrice Piola'].sort
    assert_equal authors, docs[9].authors.map(&:full).sort

    assert_nil docs[1].fulltext
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

    assert_nil doc.fulltext
    refute_nil doc.term_vectors

    assert_equal 2, doc.term_vectors['decrease'][:tf]
    assert_equal 21, doc.term_vectors['hyperendemic'][:positions][0]
    assert_equal 389, doc.term_vectors['population'][:df]
    assert_nil doc.term_vectors['zuzax']
  end
end
