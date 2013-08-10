# -*- encoding : utf-8 -*-
require 'spec_helper'

SimpleCov.command_name 'spec:lib' if defined?(SimpleCov)

describe NameHelpers do

  describe '.name_to_lucene' do
    it 'creates simple query for last-only name' do
      expected = ['Last']
      expect(NameHelpers.name_to_lucene('Last')).to be_lucene_query(expected)
    end

    it 'creates correct queries for F Last' do
      expected = ['F* Last']
      expect(NameHelpers.name_to_lucene('F Last')).to be_lucene_query(expected)
    end

    it 'creates correct queries for FMM Last' do
      expected = ['F* Last', 'F* M* M* Last']
      expect(NameHelpers.name_to_lucene('FMM Last')).to be_lucene_query(expected)
    end

    it 'creates correct queries for First Last' do
      expected = ['F Last', 'First Last']
      expect(NameHelpers.name_to_lucene('First Last')).to be_lucene_query(expected)
    end

    it 'creates correct queries for First M M Last' do
      expected = ['F M* M* Last', 'First M* M* Last', 'First Last',
        'F Last']
      expect(NameHelpers.name_to_lucene('First M M Last')).to be_lucene_query(expected)
    end

    it 'creates correct queries for First MM Last' do
      expected = ['F M* M* Last', 'First M* M* Last', 'First Last',
        'F Last']
      expect(NameHelpers.name_to_lucene('First MM Last')).to be_lucene_query(expected)
    end

    it 'creates correct queries for First Middle Middle Last' do
      expected = ['First Last', 'F Last', 'First Middle Middle Last',
        'First Middle M Last', 'First M Middle Last', 'First M M Last',
        'First MM Last', 'F Middle Middle Last', 'F Middle M Last',
        'F M Middle Last', 'FM Middle Last', 'F M M Last', 'FMM Last',
        'FM M Last', 'F MM Last']
      expect(NameHelpers.name_to_lucene('First Middle Middle Last')).to be_lucene_query(expected)
    end
  end

end
