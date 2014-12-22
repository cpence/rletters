# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Solr::CorpusStats do
  before(:example) do
    @stats = described_class.new
  end

  describe '#size' do
    it 'works' do
      expect(@stats.size).to eq(1502)
    end
  end
end
