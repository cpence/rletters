# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::Analysis::NamedEntities, nlp: false do
  describe '.available?' do
    it 'is false' do
      expect(Jobs::Analysis::NamedEntities.available?).to be false
    end
  end
end

describe Jobs::Analysis::NamedEntities, nlp: true do
  it_should_behave_like 'an analysis job with a file'

  describe '.download?' do
    it 'is false' do
      expect(Jobs::Analysis::NamedEntities.download?).to be false
    end
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(Jobs::Analysis::NamedEntities.num_datasets).to eq(1)
    end
  end
end
