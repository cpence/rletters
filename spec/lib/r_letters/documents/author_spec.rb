# -*- encoding : utf-8 -*-
require 'spec_helper'

def query_to_array(str)
  return [str[1..-2]] unless str[0] == '('
  str[1..-2].split(' OR ').map { |n| n[1..-2] }
end

describe RLetters::Documents::Author do
  describe '#full' do
    it 'returns whatever was passed into the constructor' do
      au = described_class.new('Greebleflotz, Johannes van der 123 Jr.')
      expect(au.full).to eq('Greebleflotz, Johannes van der 123 Jr.')
    end
  end

  describe '#first' do
    it 'returns nothing with just one name' do
      au = described_class.new('Asdf')
      expect(au.first).to be_nil
    end

    it 'returns as expected with no comma' do
      au = described_class.new('Asdf Sdfg')
      expect(au.first).to eq('Asdf')
    end

    it 'returns as expected with comma' do
      au = described_class.new('Sdfg, Asdf')
      expect(au.first).to eq('Asdf')
    end
  end

  describe '#last' do
    it 'returns the name with just one name' do
      au = described_class.new('Asdf')
      expect(au.last).to eq('Asdf')
    end

    it 'returns as expected with no comma' do
      au = described_class.new('Asdf Sdfg')
      expect(au.last).to eq('Sdfg')
    end

    it 'returns as expected with comma' do
      au = described_class.new('Sdfg, Asdf')
      expect(au.last).to eq('Sdfg')
    end
  end

  describe '#prefix' do
    it 'returns as expected with no comma' do
      au = described_class.new('Asdf van der Sdfg')
      expect(au.prefix).to eq('van der')
    end

    it 'returns as expected with comma' do
      au = described_class.new('Van der Sdfg, Asdf')
      expect(au.prefix).to eq('Van der')
    end
  end

  describe '#suffix' do
    # N.B.: the BibTeX::Names parser does not pull out suffixes without comma
    it 'returns as expected with comma' do
      au = described_class.new('van der Sdfg, Jr., Asdf')
      expect(au.suffix).to eq('Jr.')
    end
  end

  describe '#to_lucene' do
    it 'creates simple query for last-only name' do
      expected = ['Last']
      actual = query_to_array(described_class.new('Last').to_lucene)

      expect(actual).to match_array(expected)
    end

    it 'creates correct queries for F Last' do
      expected = ['F* Last']
      actual = query_to_array(described_class.new('F Last').to_lucene)

      expect(actual).to match_array(expected)
    end

    it 'creates correct queries for FMM Last' do
      expected = ['F* Last', 'F* M* M* Last']
      actual = query_to_array(described_class.new('FMM Last').to_lucene)

      expect(actual).to match_array(expected)
    end

    it 'creates correct queries for First Last' do
      expected = ['F Last', 'First Last']
      actual = query_to_array(described_class.new('First Last').to_lucene)

      expect(actual).to match_array(expected)
    end

    it 'creates correct queries for First M M Last' do
      expected = ['F M* M* Last', 'First M* M* Last', 'First Last',
                  'F Last']
      actual = query_to_array(described_class.new('First M M Last').to_lucene)

      expect(actual).to match_array(expected)
    end

    it 'creates correct queries for First MM Last' do
      expected = ['F M* M* Last', 'First M* M* Last', 'First Last',
                  'F Last']
      actual = query_to_array(described_class.new('First MM Last').to_lucene)

      expect(actual).to match_array(expected)
    end

    it 'creates correct queries for First Middle Middle Last' do
      expected = ['First Last', 'F Last', 'First Middle Middle Last',
                  'First Middle M Last', 'First M Middle Last',
                  'First M M Last', 'First MM Last', 'F Middle Middle Last',
                  'F Middle M Last', 'F M Middle Last', 'FM Middle Last',
                  'F M M Last', 'FMM Last', 'FM M Last', 'F MM Last']
      actual = query_to_array(described_class.new('First Middle Middle Last').to_lucene)

      expect(actual).to match_array(expected)
    end
  end

  describe '#to_citeproc' do
    it 'works as expected' do
      citeproc = described_class.new('First M M Last').to_citeproc
      expect(citeproc['family']).to eq('Last')
      expect(citeproc['given']).to eq('First M M')
    end
  end
end
