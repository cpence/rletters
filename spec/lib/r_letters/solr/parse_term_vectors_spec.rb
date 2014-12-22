# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Solr::ParseTermVectors do
  context 'with good vectors' do
    before(:example) do
      solr_result = build(:solr_response).response
      array = solr_result['termVectors']

      @parser = described_class.new(array)
      @result = @parser.for_document('doi:10.5678/dickens')

      @doc = build(:full_document)
    end

    it 'parses as expected' do
      expect(@result.deep_stringify_keys).to eq(@doc.term_vectors.deep_stringify_keys)
    end

    it 'returns an empty hash for missing documents' do
      expect(@parser.for_document('nope')).to eq({})
    end
  end

  context 'with empty document vectors' do
    before(:example) do
      empty_array = [
        'uniqueKeyFieldName','uid',
        'nope', ['uniqueKey','nope','fulltext',[]]
      ]

      @parser = described_class.new(empty_array)
    end

    it 'returns an empty hash' do
      expect(@parser.for_document('nope')).to eq({})
    end
  end
end
