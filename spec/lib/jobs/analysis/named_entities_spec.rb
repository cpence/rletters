# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::Analysis::NamedEntities, nlp: false do
  describe '.available?' do
    it 'is false' do
      expect(Jobs::Analysis::NamedEntities).to be_false
    end
  end
end

describe Jobs::Analysis::NamedEntities, nlp: true do
  it_should_behave_like 'an analysis job with a file'
end
