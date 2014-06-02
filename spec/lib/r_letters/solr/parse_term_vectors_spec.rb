# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'support/doubles/term_vector_solr_array'
require 'support/doubles/term_vector_hash'

RSpec.describe RLetters::Solr::ParseTermVectors do
  before(:example) do
    @array = term_vector_solr_array
    @parser = described_class.new(@array)
    @result = @parser.for_document('doi:10.1234/5678')
  end

  it 'parses as expected' do
    expect(@result).to eq(term_vector_hash)
  end

  it 'returns an empty hash for missing documents' do
    expect(@parser.for_document('nope')).to eq({})
  end
end
