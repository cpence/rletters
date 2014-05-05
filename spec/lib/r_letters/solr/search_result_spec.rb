# -*- encoding : utf-8 -*-
require 'spec_helper'

describe RLetters::Solr::SearchResult do
  before(:each) do
    stub_const('Document', Class.new)
    allow(Document).to receive(:new).with(any_args())

    document_solr_hash = {
      'data_source' => 'Test fixture',
      'license' => 'Public domain',
      'uid' => 'doi:10.1234/5678',
      'doi' => '10.1234/5678',
      'authors' => 'A. One, B. Two',
      'title' => 'Test Title',
      'journal' => 'Journal',
      'year' => '2010',
      'volume' => '100',
      'number' => '200',
      'pages' => '100-200'
    }

    documents_array = [document_solr_hash, document_solr_hash]

    @mock_response = double
    allow(@mock_response).to receive(:ok?).and_return(true)
    allow(@mock_response).to receive(:total).and_return(100)
    allow(@mock_response).to receive(:docs).and_return(documents_array)
    allow(@mock_response).to receive(:facets).and_return(nil)
    allow(@mock_response).to receive(:facet_queries).and_return(nil)
    allow(@mock_response).to receive(:[]).with('termVectors').and_return(nil)
    allow(@mock_response).to receive(:params).and_return({})
  end

  describe '#solr_response' do
    it 'returns what was passed to #new' do
      expect(described_class.new(@mock_response).solr_response).to eq(@mock_response)
    end

    it 'throws an exception if the response is not okay' do
      fail_response = double
      allow(fail_response).to receive(:ok?).and_return(false)
      allow(fail_response).to receive(:params).and_return({})

      expect {
        described_class.new(fail_response)
      }.to raise_error(RLetters::Solr::ConnectionError)
    end
  end

  describe '#documents' do
    context 'when loading documents' do
      it 'loads the documents' do
        expect(described_class.new(@mock_response).documents.size).to eq(2)
      end

      it 'passes the document hashes to the Document constructor' do
        expect(Document).to receive(:new).with(@mock_response.docs[0])
        described_class.new(@mock_response)
      end

      it 'passes the term vector hashes to the TV parser' do
        allow(@mock_response).to receive(:[]).with('termVectors').and_return(123)

        mock_parser = double
        expect(mock_parser).to receive(:for_document).with('doi:10.1234/5678').twice

        stub_const('RLetters::Solr::ParseTermVectors', Class.new)
        expect(RLetters::Solr::ParseTermVectors).to receive(:new).with(123).and_return(mock_parser)

        described_class.new(@mock_response)
      end
    end

    context 'when no documents are returned' do
      it 'returns an empty array' do
        allow(@mock_response).to receive(:docs).and_return([])
        expect(described_class.new(@mock_response).documents).to be_empty
      end
    end
  end

  describe '#num_hits' do
    it 'sets num_hits to the value of :total' do
      expect(described_class.new(@mock_response).num_hits).to eq(100)
    end
  end

  describe '#facets' do
    before(:each) do
      allow(@mock_response).to receive(:facets).and_return(123)
      allow(@mock_response).to receive(:facet_queries).and_return(456)
    end

    it 'creates a facets object with the data' do
      stub_const('RLetters::Solr::Facets', Class.new)
      expect(RLetters::Solr::Facets).to receive(:new).with(123, 456).and_return(true)

      described_class.new(@mock_response)
    end
  end
end
