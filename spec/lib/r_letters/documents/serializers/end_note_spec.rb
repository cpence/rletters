# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Documents::Serializers::EndNote do

  context 'when serializing a single document' do
    before(:example) do
      @doc = build(:full_document)
      @str = described_class.new(@doc).serialize
    end

    it 'creates good EndNote' do
      expect(@str).to be_start_with("%0 Journal Article\n")
      expect(@str).to include('%A One, A.')
      expect(@str).to include('%A Two, B.')
      expect(@str).to include('%T Test Title')
      expect(@str).to include('%J Journal')
      expect(@str).to include('%V 10')
      expect(@str).to include('%N 20')
      expect(@str).to include('%P 100-200')
      expect(@str).to include('%M 10.1234/5678')
      expect(@str).to include('%D 2010')
      # This extra carriage return is the item separator, and is thus very
      # important
      expect(@str).to be_end_with("\n\n")
    end
  end

  context 'when serializing an array of documents' do
    before(:example) do
      doc = build(:full_document)
      @docs = [doc, doc]
      @str = described_class.new(@docs).serialize
    end

    it 'creates good EndNote' do
      expect(@str).to be_start_with("%0 Journal Article\n")
      expect(@str).to include("\n\n%0 Journal Article\n")
    end
  end

end
