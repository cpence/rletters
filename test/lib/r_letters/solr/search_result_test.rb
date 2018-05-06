# frozen_string_literal: true
require 'test_helper'
require 'r_letters/solr/connection'

class RLetters::Solr::SearchResultTest < ActiveSupport::TestCase
  test 'solr_response returns what was passed to new' do
    solr_result = build(:solr_response).response
    rsolr = RSolr::Ext::Response::Base.new(solr_result, 'search', nil)

    res = RLetters::Solr::SearchResult.new(rsolr)

    assert_equal rsolr, res.solr_response
  end

  test 'solr_response throws if the response is bad' do
    fail_response = stub(ok?: false, params: {})

    assert_raises(RLetters::Solr::ConnectionError) do
      RLetters::Solr::SearchResult.new(fail_response)
    end
  end

  test 'loads the right number of documents' do
    solr_result = build(:solr_response).response
    rsolr = RSolr::Ext::Response::Base.new(solr_result, 'search', nil)

    res = RLetters::Solr::SearchResult.new(rsolr)

    assert_equal 1, res.documents.size
  end

  test 'passes the document hash straight to the constructor' do
    solr_result = build(:solr_response).response
    rsolr = RSolr::Ext::Response::Base.new(solr_result, 'search', nil)

    Document.expects(:new).with(rsolr.docs[0])

    RLetters::Solr::SearchResult.new(rsolr)
  end

  test 'passes term vector hashes to their parser' do
    mock_parser = mock()
    mock_parser.expects(:for_document).with('doi:10.5678/dickens')
    RLetters::Solr::ParseTermVectors.expects(:new)
      .returns(mock_parser)

    solr_result = build(:solr_response).response
    rsolr = RSolr::Ext::Response::Base.new(solr_result, 'search', nil)

    RLetters::Solr::SearchResult.new(rsolr)
  end

  test 'returns empty documents array when no documents are returned' do
    solr_result = build(:solr_response).response
    solr_result['response']['docs'] = []
    rsolr = RSolr::Ext::Response::Base.new(solr_result, 'search', nil)

    res = RLetters::Solr::SearchResult.new(rsolr)

    assert_empty res.documents
  end

  test 'num_hits works' do
    solr_result = build(:solr_response).response
    rsolr = RSolr::Ext::Response::Base.new(solr_result, 'search', nil)

    res = RLetters::Solr::SearchResult.new(rsolr)

    assert_equal 1, res.num_hits
  end

  test 'facets builds a facets object with the data' do
    solr_result = build(:solr_response).response
    rsolr = RSolr::Ext::Response::Base.new(solr_result, 'search', nil)

    RLetters::Solr::Facets.expects(:new)
      .with(rsolr.facets, rsolr.facet_queries)

    RLetters::Solr::SearchResult.new(rsolr)
  end
end
