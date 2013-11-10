# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'nokogiri'

describe Serializers::MODS do

  context 'when serializing a single document' do
    before(:each) do
      @doc = FactoryGirl.build(:full_document, number: '12')
      @xml = @doc.to_mods
    end

    it 'creates good MODS documents' do
      # This test is incomplete, but we'll validate the schema in the next test
      expect(@xml.at_css('mods titleInfo title').content).to eq('How Reliable are the Methods for Estimating Repertoire Size?')
      expect(@xml.at_css('mods name namePart').content).to eq('Carlos A.')
      expect(@xml.at_css('mods originInfo dateIssued').content).to eq('2008')
      expect(@xml.at_css('mods relatedItem titleInfo title').content).to eq('Ethology')
      expect(@xml.at_css('mods relatedItem originInfo dateIssued').content).to eq('2008')
      expect(@xml.at_css('mods relatedItem part detail number:contains("114")')).to be
      expect(@xml.at_css('mods relatedItem part detail number:contains("12")')).to be
      expect(@xml.at_css('mods relatedItem part extent start').content).to eq('1227')
      expect(@xml.at_css('mods relatedItem part date').content).to eq('2008')
      expect(@xml.at_css('mods identifier').content).to eq('10.1111/j.1439-0310.2008.01576.x')
    end

    it 'creates MODS documents that are valid against the schema' do
      xsd = Nokogiri::XML::Schema.new(File.open(Rails.root.join('spec', 'support', 'xsd', 'mods-3-4.xsd')))

      errors = xsd.validate(@xml)
      fail(errors.map { |e| e.to_s }.join('; ')) if errors.length != 0
    end
  end

  context 'when serializing an array of documents' do
    before(:each) do
      doc = FactoryGirl.build(:full_document)
      doc2 = FactoryGirl.build(:full_document, uid: 'wut')

      @docs = [doc, doc2]
      @xml = @docs.to_mods
    end

    it 'creates good MODS collections' do
      expect(@xml.at_css('modsCollection mods titleInfo title').content).to eq('How Reliable are the Methods for Estimating Repertoire Size?')
      expect(@xml.at_css('modsCollection').children.count).to eq(2)
    end

    it 'creates MODS collections that are valid against the schema' do
      xsd = Nokogiri::XML::Schema.new(File.open(Rails.root.join('spec', 'support', 'xsd', 'mods-3-4.xsd')))

      errors = xsd.validate(@xml)
      fail(errors.map { |e| e.to_s }.join('; ')) if errors.length != 0
    end
  end

end
