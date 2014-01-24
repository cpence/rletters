# -*- encoding : utf-8 -*-
require 'r_letters/datasets/document_enumerator'
require 'r_letters/solr/count_by_field'

require 'support/doubles/dataset_fulltext'
require 'support/doubles/grouped_solr_hash'

describe RLetters::Solr::CountByField do
  before(:each) do
    stub_const('RLetters::Solr::Connection', Class.new)
    stub_const('RLetters::Solr::ConnectionError', Class.new)
    stub_const('RLetters::Solr::Connection::DEFAULT_FIELDS', 'default_fields')
    stub_const('RLetters::Solr::Connection::DEFAULT_FIELDS_FULLTEXT', 'fulltext_fields')
  end

  describe '#counts_for' do
    context 'without a dataset' do
      before(:each) do
        expect(RLetters::Solr::Connection).to receive(:search_raw).and_return(grouped_solr_hash)
        @counts = described_class.new.counts_for(:year)
      end

      it 'gets the values for the whole corpus' do
        expect(@counts['2009']).to eq(123)
        expect(@counts['2007']).to eq(456)
      end
    end

    context 'without a dataset, with Solr failure' do
      it 'is empty' do
        expect(RLetters::Solr::Connection).to receive(:search_raw).and_return({})
        expect(described_class.new.counts_for(:year)).to eq({})
      end
    end

    context 'with a dataset' do
      before(:each) do
        @dataset = double_dataset_fulltext
        @doc_1 = stub_document_fulltext
        @doc_2 = stub_document_fulltext(uid: 'doi:10.2345/6789', doi: '10.2345/6789')
        result = double(documents: [@doc_1, @doc_2], num_hits: 2)

        expect(RLetters::Solr::Connection).to receive(:search).and_return(result)
        @counts = described_class.new(@dataset).counts_for(:year)
      end

      it 'gets the values for the dataset' do
        expect(@counts.size).to eq(1)
        expect(@counts['2010']).to eq(2)
      end
    end

    context 'without a dataset, with Solr failure' do
      it 'is empty' do
        expect(RLetters::Solr::Connection).to receive(:search_raw).and_return({})
        expect(described_class.new(@dataset).counts_for(:year)).to eq({})
      end
    end
  end
end
