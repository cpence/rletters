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
      @xml.at_xpath('xmlns:mods/xmlns:titleInfo/xmlns:title').content.should eq('How Reliable are the Methods for Estimating Repertoire Size?')
      @xml.at_xpath('xmlns:mods/xmlns:name/xmlns:namePart').content.should eq('Carlos A.')
      @xml.at_xpath('xmlns:mods/xmlns:originInfo/xmlns:dateIssued').content.should eq('2008')
      @xml.at_xpath('xmlns:mods/xmlns:relatedItem/xmlns:titleInfo/xmlns:title').content.should eq('Ethology')
      @xml.at_xpath('xmlns:mods/xmlns:relatedItem/xmlns:originInfo/xmlns:dateIssued').content.should eq('2008')
      @xml.at_xpath('xmlns:mods/xmlns:relatedItem/xmlns:part/xmlns:detail[@type = "volume"]/xmlns:number').content.should eq('114')
      @xml.at_xpath('xmlns:mods/xmlns:relatedItem/xmlns:part/xmlns:detail[@type = "issue"]/xmlns:number').content.should eq('12')
      @xml.at_xpath('xmlns:mods/xmlns:relatedItem/xmlns:part/xmlns:extent/xmlns:start').content.should eq('1227')
      @xml.at_xpath('xmlns:mods/xmlns:relatedItem/xmlns:part/xmlns:date').content.should eq('2008')
      @xml.at_xpath('xmlns:mods/xmlns:identifier').content.should eq('10.1111/j.1439-0310.2008.01576.x')
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
      @xml.at_xpath('xmlns:modsCollection/xmlns:mods[1]/xmlns:titleInfo/xmlns:title').content.should eq('How Reliable are the Methods for Estimating Repertoire Size?')
      @xml.at_xpath('xmlns:modsCollection').children.to_a.should have(2).elements
    end

    it 'creates MODS collections that are valid against the schema' do
      xsd = Nokogiri::XML::Schema.new(File.open(Rails.root.join('spec', 'support', 'xsd', 'mods-3-4.xsd')))

      errors = xsd.validate(@xml)
      fail_with(errors.map { |e| e.to_s }.join('; ')) if errors.length != 0
    end
  end

end
