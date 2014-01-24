# -*- encoding : utf-8 -*-
require 'r_letters/datasets/document_enumerator'

require 'support/doubles/dataset_fulltext'

describe RLetters::Datasets::DocumentEnumerator do
  before(:each) do
    @dataset = double_dataset_fulltext
    @doc_1 = stub_document_fulltext
    @doc_2 = stub_document_fulltext(uid: 'doi:10.2345/6789', doi: '10.2345/6789')

    stub_const('RLetters::Solr', Module.new)
    stub_const('RLetters::Solr::Connection', Class.new)
    stub_const('RLetters::Solr::Connection::DEFAULT_FIELDS', 'default_fields')
    stub_const('RLetters::Solr::Connection::DEFAULT_FIELDS_FULLTEXT', 'fulltext_fields')
  end

  context 'with no custom fields' do
    before(:each) do
      @enum = RLetters::Datasets::DocumentEnumerator.new(@dataset)
    end

    it 'enumerates the documents as expected' do
      query = {
        q: 'uid:("doi:10.1234/5678" OR "doi:10.2345/6789")',
        def_type: 'lucene',
        facet: false,
        fl: 'default_fields',
        rows: 2
      }
      result = double(documents: [@doc_1, @doc_2], num_hits: 2)

      expect(RLetters::Solr::Connection).to receive(:search).with(query).and_return(result)
      @enum.each { |d| expect([@doc_1, @doc_2]).to include(d) }
    end

    it 'throws if the Solr server fails' do
      result = double(documents: [], num_hits: 0)
      expect(RLetters::Solr::Connection).to receive(:search).and_return(result)
      expect {
        @enum.each { |d| }
      }.to raise_error(RuntimeError)
    end
  end

  context 'with fulltext fields' do
    before(:each) do
      @enum = RLetters::Datasets::DocumentEnumerator.new(@dataset, fulltext: true)
    end

    it 'enumerates the documents as expected' do
      query = {
        q: 'uid:("doi:10.1234/5678" OR "doi:10.2345/6789")',
        def_type: 'lucene',
        facet: false,
        fl: 'fulltext_fields',
        rows: 2
      }
      result = double(documents: [@doc_1, @doc_2], num_hits: 2)

      expect(RLetters::Solr::Connection).to receive(:search).with(query).and_return(result)
      @enum.each { |d| expect([@doc_1, @doc_2]).to include(d) }
    end
  end

  context 'with custom fields' do
    before(:each) do
      @enum = RLetters::Datasets::DocumentEnumerator.new(@dataset, fl: 'year')
    end

    it 'enumerates the documents as expected' do
      query = {
        q: 'uid:("doi:10.1234/5678" OR "doi:10.2345/6789")',
        def_type: 'lucene',
        facet: false,
        fl: 'year',
        rows: 2
      }
      result = double(documents: [@doc_1, @doc_2], num_hits: 2)

      expect(RLetters::Solr::Connection).to receive(:search).with(query).and_return(result)
      @enum.each { |d| expect([@doc_1, @doc_2]).to include(d) }
    end
  end
end
