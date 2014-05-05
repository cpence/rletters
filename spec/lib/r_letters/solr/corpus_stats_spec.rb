# -*- encoding : utf-8 -*-
require 'spec_helper'

describe RLetters::Solr::CorpusStats do
  before(:each) do
    @stats = described_class.new
  end

  describe '#size' do
    it 'works' do
      expect(@stats.size).to eq(1043)
    end
  end
end
