# -*- encoding : utf-8 -*-
require 'spec_helper'

describe RLetters::Documents::Serializers::RDFXML do

  context 'with a single document' do
    before(:each) do
      @doc = FactoryGirl.build(:full_document)
      @xml = Nokogiri::XML::Document.parse(described_class.new(@doc).serialize)
    end

    it 'creates an rdf root element' do
      expect(@xml.root.name).to eq('rdf')
    end

    it 'includes a single description element' do
      expect(@xml.css('Description').count).to eq(1)
    end

    it 'includes a few of the important Dublin Core elements' do
      expect(@xml.at_css('dc|title').content).to eq(@doc.title)
      expect(@xml.at_css('dc|relation').content).to eq(@doc.journal)
      expect(@xml.at_css('dc|type').content).to eq('Journal Article')
    end
  end

  context 'with an array of documents' do
    before(:each) do
      doc = FactoryGirl.build(:full_document)
      doc2 = FactoryGirl.build(:full_document, uid: 'wut')

      @docs = [doc, doc2]
      @xml = Nokogiri::XML::Document.parse(described_class.new(@docs).serialize)
    end

    it 'includes two description elements' do
      expect(@xml.css('Description').count).to eq(2)
    end
  end

end
