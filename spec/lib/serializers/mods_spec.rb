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
      expect(@xml.at_xpath('xmlns:mods/xmlns:titleInfo/xmlns:title').content).to eq('How Reliable are the Methods for Estimating Repertoire Size?')
      expect(@xml.at_xpath('xmlns:mods/xmlns:name/xmlns:namePart').content).to eq('Carlos A.')
      expect(@xml.at_xpath('xmlns:mods/xmlns:originInfo/xmlns:dateIssued').content).to eq('2008')
      expect(@xml.at_xpath('xmlns:mods/xmlns:relatedItem/xmlns:titleInfo/xmlns:title').content).to eq('Ethology')
      expect(@xml.at_xpath('xmlns:mods/xmlns:relatedItem/xmlns:originInfo/xmlns:dateIssued').content).to eq('2008')
      expect(@xml.at_xpath('xmlns:mods/xmlns:relatedItem/xmlns:part/xmlns:detail[@type = "volume"]/xmlns:number').content).to eq('114')
      expect(@xml.at_xpath('xmlns:mods/xmlns:relatedItem/xmlns:part/xmlns:detail[@type = "issue"]/xmlns:number').content).to eq('12')
      expect(@xml.at_xpath('xmlns:mods/xmlns:relatedItem/xmlns:part/xmlns:extent/xmlns:start').content).to eq('1227')
      expect(@xml.at_xpath('xmlns:mods/xmlns:relatedItem/xmlns:part/xmlns:date').content).to eq('2008')
      expect(@xml.at_xpath('xmlns:mods/xmlns:identifier').content).to eq('10.1111/j.1439-0310.2008.01576.x')
    end

    it 'creates MODS documents that are valid against the schema' do
      xsd = Nokogiri::XML::Schema.new(File.open(Rails.root.join('spec', 'support', 'xsd', 'mods-3-4.xsd')))

      errors = xsd.validate(@xml)
      fail_with(errors.map { |e| e.to_s }.join('; ')) if errors.length != 0
    end
  end

  context 'when serializing an array of documents' do
    before(:each) do
      doc = FactoryGirl.build(:full_document)
      doc2 = FactoryGirl.build(:full_document, shasum: 'wut')

      @docs = [doc, doc2]
      @xml = @docs.to_mods
    end

    it 'creates good MODS collections' do
      expect(@xml.at_xpath('xmlns:modsCollection/xmlns:mods[1]/xmlns:titleInfo/xmlns:title').content).to eq('How Reliable are the Methods for Estimating Repertoire Size?')
      expect(@xml.at_xpath('xmlns:modsCollection').children.to_a).to have(2).elements
    end

    it 'creates MODS collections that are valid against the schema' do
      xsd = Nokogiri::XML::Schema.new(File.open(Rails.root.join('spec', 'support', 'xsd', 'mods-3-4.xsd')))

      errors = xsd.validate(@xml)
      fail_with(errors.map { |e| e.to_s }.join('; ')) if errors.length != 0
    end
  end

end
