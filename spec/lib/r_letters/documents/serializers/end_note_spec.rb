# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Documents::Serializers::EndNote do

  context 'when serializing a single document' do
    before(:example) do
      @doc = build(:full_document)
      @str = described_class.new(@doc).serialize
    end

    it 'creates good EndNote' do
      expect(@str).to start_with("%0 Journal Article\n")
      expect(@str).to include('%A Dickens, C.')
      expect(@str).to include('%T A Tale of Two Cities')
      expect(@str).to include('%J Actually a Novel')
      expect(@str).to include('%V 1')
      expect(@str).to include('%N 1')
      expect(@str).to include('%P 1')
      expect(@str).to include('%M 10.5678/dickens')
      expect(@str).to include('%D 1859')
      # This extra carriage return is the item separator, and is thus very
      # important
      expect(@str).to end_with("\n\n")
    end
  end

  context 'when serializing an array of documents' do
    before(:example) do
      doc = build(:full_document)
      @docs = [doc, doc]
      @str = described_class.new(@docs).serialize
    end

    it 'creates good EndNote' do
      expect(@str).to start_with("%0 Journal Article\n")
      expect(@str).to include("\n\n%0 Journal Article\n")
    end
  end

end
