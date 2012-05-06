# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Serializers::RIS do
  
  context "when serializing a single document" do
    before(:each) do
      @doc = FactoryGirl.build(:full_document)
      @str = @doc.to_ris
    end
    
    it "creates good RIS" do
      @str.should be_start_with("TY  - JOUR\n")
      @str.should include("AU  - Botero,Carlos A.")
      @str.should include("AU  - Mudge,Andrew E.")
      @str.should include("AU  - Koltz,Amanda M.")
      @str.should include("AU  - Hochachka,Wesley M.")
      @str.should include("AU  - Vehrencamp,Sandra L.")
      @str.should include("TI  - How Reliable are the Methods for Estimating Repertoire Size?")
      @str.should include("JO  - Ethology")
      @str.should include("VL  - 114")
      @str.should include("SP  - 1227")
      @str.should include("EP  - 1238")
      @str.should include("PY  - 2008")
      @str.should be_end_with("ER  - \n")
    end
  end
  
  context "when serializing an array of documents" do
    before(:each) do
      doc = FactoryGirl.build(:full_document)
      @docs = [doc, doc]
      @str = @docs.to_ris
    end
    
    it "creates good RIS" do
      @str.should be_start_with("TY  - JOUR\n")
      @str.should include("ER  - \nTY  - JOUR\n")
    end
  end
  
end
