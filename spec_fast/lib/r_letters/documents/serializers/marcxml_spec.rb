# -*- encoding : utf-8 -*-
require 'r_letters/documents/serializers/marcxml'
require 'support/doubles/document_basic'
require 'nokogiri'

describe RLetters::Documents::Serializers::MARCXML do

  context 'when serializing an array of documents' do
    before(:each) do
      doc = double_document_basic
      @docs = [doc, doc]
      @xml = Nokogiri::XML::Document.parse(described_class.new(@docs).serialize)
    end

    it 'creates MARCXML collections of the right size' do
      expect(@xml.css('collection record').size).to eq(2)
    end
  end

end
