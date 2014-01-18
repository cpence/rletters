# -*- encoding : utf-8 -*-
require 'spec_helper'

describe RLetters::Documents::Serializers::MARCXML do

  context 'when serializing an array of documents' do
    before(:each) do
      doc = FactoryGirl.build(:full_document)
      @docs = [doc, doc]
      @xml = Nokogiri::XML::Document.parse(described_class.new(@docs).serialize)
    end

    it 'creates MARCXML collections of the right size' do
      expect(@xml.css('collection record').count).to eq(2)
    end
  end

end
