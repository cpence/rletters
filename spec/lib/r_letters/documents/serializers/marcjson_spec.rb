# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Documents::Serializers::MARCJSON do

  context 'when serializing an array of documents' do
    before(:example) do
      doc = build(:full_document)
      @docs = [doc, doc]
      @json = described_class.new(@docs).serialize
      @parsed = JSON.load(@json)
    end

    it 'creates MARC-JSON collections of the right size' do
      expect(@parsed).to be_an(Array)
      expect(@parsed.size).to eq(2)
    end
  end

end
