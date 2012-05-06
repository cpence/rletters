# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Serializers::EndNote do
  
  context "when serializing a single document" do
    before(:each) do
      @doc = FactoryGirl.build(:full_document)
      @str = @doc.to_endnote
    end
    
    it "creates good EndNote" do
      @str.should be_start_with("%0 Journal Article\n")
      @str.should include("%A Botero, Carlos A.")
      @str.should include("%A Mudge, Andrew E.")
      @str.should include("%A Koltz, Amanda M.")
      @str.should include("%A Hochachka, Wesley M.")
      @str.should include("%A Vehrencamp, Sandra L.")
      @str.should include("%T How Reliable are the Methods for Estimating Repertoire Size?")
      @str.should include("%J Ethology")
      @str.should include("%V 114")
      @str.should include("%P 1227-1238")
      @str.should include("%M 10.1111/j.1439-0310.2008.01576.x")
      @str.should include("%D 2008")
      # This extra carriage return is the item separator, and is thus very 
      # important
      @str.should be_end_with("\n\n")
    end
  end
  
  context "when serializing an array of documents" do
    before(:each) do
      doc = FactoryGirl.build(:full_document)
      @docs = [doc, doc]
      @str = @docs.to_endnote
    end
    
    it "creates good EndNote" do
      @str.should be_start_with("%0 Journal Article\n")
      @str.should include("\n\n%0 Journal Article\n")
    end
  end
  
end
