# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Analysis::NamedEntities do
  # FIXME: rework a double for this
  # describe '#entity_references' do
  #   before(:each) do
  #     @dataset = stub_stanford_ner_classifier
  #     @analyzer = described_class.new(@dataset)
  #   end

  #   it 'works as expected' do
  #     expect(@analyzer.entity_references['PERSON']).to include('Susan G. Brown')
  #     expect(@analyzer.entity_references['LOCATION']).to include('London')
  #   end
  # end

  # describe '#progress' do
  #   it 'calls the progress function with under and equal to 100' do
  #     called_sub_100 = false
  #     called_100 = false

  #     @dataset = stub_stanford_ner_classifier
  #     @analyzer = described_class.new(@dataset, ->(p) {
  #       if p < 100
  #         called_sub_100 = true
  #       else
  #         called_100 = true
  #       end
  #     })

  #     expect(called_sub_100).to be true
  #     expect(called_100).to be true
  #   end
  # end
end
