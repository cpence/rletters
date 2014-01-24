# -*- encoding : utf-8 -*-
require 'r_letters/solr/parse_term_vectors'

require 'support/doubles/term_vector_solr_array'
require 'support/doubles/term_vector_hash'

describe RLetters::Solr::ParseTermVectors do
  before(:each) do
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
