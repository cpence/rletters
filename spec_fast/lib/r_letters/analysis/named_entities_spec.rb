# -*- encoding : utf-8 -*-
require 'r_letters/datasets/document_enumerator'
require 'r_letters/analysis/named_entities'

require 'support/doubles/stanford_ner_classifier'

describe RLetters::Analysis::NamedEntities do
  before(:each) do
    @dataset = stub_stanford_ner_classifier
    @analyzer = described_class.new(@dataset)
  end

  it 'works as expected' do
    expect(@analyzer.entity_references['PERSON']).to include('Susan G. Brown')
    expect(@analyzer.entity_references['LOCATION']).to include('London')
  end
end
