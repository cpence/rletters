# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Serializers::MODS do
  
  context "when serializing a single document" do
    before(:each) do
      @doc = FactoryGirl.build(:full_document, :number => '12')
      @xml = @doc.to_mods
    end
    
    it "creates good MODS documents" do
      # This test is incomplete, but we'll validate the schema in the next test
      @xml.elements['mods/titleInfo/title'].text.should eq("How Reliable are the Methods for Estimating Repertoire Size?")
      @xml.elements['mods/name/namePart'].text.should eq("Carlos A.")
      @xml.elements['mods/originInfo/dateIssued'].text.should eq("2008")
      @xml.elements['mods/relatedItem/titleInfo/title'].text.should eq("Ethology")
      @xml.elements['mods/relatedItem/originInfo/dateIssued'].text.should eq("2008")
      @xml.elements['mods/relatedItem/part/detail[@type = "volume"]/number'].text.should eq("114")
      @xml.elements['mods/relatedItem/part/detail[@type = "issue"]/number'].text.should eq("12")
      @xml.elements['mods/relatedItem/part/extent/start'].text.should eq("1227")
      @xml.elements['mods/relatedItem/part/date'].text.should eq("2008")
      @xml.elements['mods/identifier'].text.should eq("10.1111/j.1439-0310.2008.01576.x")
    end
    
    it "creates MODS documents that are valid against the schema" do
      xml_str = ''
      @xml.write(xml_str)

      noko_doc = Nokogiri::XML::Document.parse(xml_str)
      xsd = Nokogiri::XML::Schema(File.open(Rails.root.join('spec', 'support', 'xsd', 'mods-3-4.xsd')))

      errors = xsd.validate(noko_doc)
      if errors.length != 0
        fail_with(errors.map { |e| e.to_s }.join('; '))
      end
    end
  end
  
  context "when serializing an array of documents" do
    before(:each) do
      doc = FactoryGirl.build(:full_document)
      doc2 = FactoryGirl.build(:full_document, :shasum => 'wut')

      @docs = [doc, doc2]
      @xml = @docs.to_mods
    end
    
    it "creates good MODS collections" do
      @xml.elements['modsCollection/mods[1]/titleInfo/title'].text.should eq("How Reliable are the Methods for Estimating Repertoire Size?")
      @xml.elements['modsCollection'].elements.size.should eq(2)
    end
    
    it "creates MODS collections that are valid against the schema" do
      xml_str = ''
      @xml.write(xml_str)

      noko_doc = Nokogiri::XML::Document.parse(xml_str)
      xsd = Nokogiri::XML::Schema(File.open(Rails.root.join('spec', 'support', 'xsd', 'mods-3-4.xsd')))

      errors = xsd.validate(noko_doc)
      if errors.length != 0
        fail_with(errors.map { |e| e.to_s }.join('; '))
      end
    end
  end
  
end
