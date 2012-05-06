# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Serializers::MARC do
  
  context "when serializing a single document" do
    before(:each) do
      @doc = FactoryGirl.build(:full_document)
      @record = @doc.to_marc
    end
    
    it "creates a good MARC::Record" do
      # Control fields
      @record['001'].value.should eq('00972c5123877961056b21aea4177d0dc69c7318')
      @record['003'].value.should eq('PDFSHASUM')
      @record['008'].value.should eq('110501s2008       ||||fo     ||0 0|eng d')
      @record['040']['a'].should eq('RLetters')
      @record['040']['b'].should eq('eng')
      @record['040']['c'].should eq('RLetters')

      # DOI field
      # Standard identifier type: stored in $2
      @record['024'].indicator1.should eq('7')
      @record['024']['2'].should eq('doi')
      @record['024']['a'].should eq('10.1111/j.1439-0310.2008.01576.x')

      # First author field
      # Name is in Last, First format
      @record['100'].indicator1.should eq('1')
      @record['100']['a'].should eq('Botero, Carlos A.')

      # All author fields
      expected = [ 'Botero, Carlos A.', 'Mudge, Andrew E.', 'Koltz, Amanda M.',
        'Hochachka, Wesley M.', 'Vehrencamp, Sandra L.' ]
      actual = []
      @record.find_all {|field| field.tag == '700' }.each do |f|
        # Name is in Last, First format
        f.indicator1.should eq('1')
        actual << f['a']
      end
      actual.should =~ expected

      # Title field
      # This is the entire title, no further information
      @record['245'].indicator1.should eq('1')
      # This field ends with a period, even when other punctuation is
      # also present
      @record['245']['a'].should eq('How Reliable are the Methods for Estimating Repertoire Size?.')

      # Journal, volume and/or number field
      # We also have an 830 entry to indicate the series
      @record['490'].indicator1.should eq('1')
      @record['490']['a'].should eq('Ethology')
      @record['490']['v'].should eq('v. 114')
      # Don't guess at non-filing characters
      @record['830'].indicator2.should eq('0')
      @record['830']['a'].should eq('Ethology')
      @record['830']['v'].should eq('v. 114')

      # "Host Item Entry" field (free-form citation data)
      # Do display this connection
      @record['773'].indicator1.should eq('0')
      @record['773']['t'].should eq('Ethology')
      # The "related parts" entry, used for the full journal citation
      @record['773']['g'].should eq('Vol. 114 (2008), p. 1227-1238')
      # An abbreviated form of the same
      @record['773']['q'].should eq('114<1227')
      # Specify this is a serial, not a human name of any sort
      @record['773']['7'].should eq('nnas')

      # Detailed date and sequence information
      # Volume
      @record['363']['a'].should eq('114')
      # FIXME: What do we do in the case of not having a number?  Should the
      # start page be listed in 'b'?
      @record['363']['c'].should eq('1227')
      @record['363']['i'].should eq('2008')

      # Date record
      # Date is properly formatted
      @record['362'].indicator1.should eq('0')
      # Always ends with a period, since we do not express date ranges
      @record['362']['a'].should eq('2008.')
    end
  end
  
  context "when serializing a document with no year" do
    before(:each) do
      @doc = FactoryGirl.build(:full_document, :year => nil)
      @record = @doc.to_marc
    end
    
    it "handles no-year documents correctly" do
      @record['008'].value.should eq('110501s0000       ||||fo     ||0 0|eng d')
    end
  end
  
  context "when serializing an array of documents" do
    before(:each) do
      doc = FactoryGirl.build(:full_document)
      @docs = [doc, doc]
    end
    
    it "creates MARCXML collections of the right size" do
      @docs.to_marc_xml.elements['collection'].elements.should have(2).items
    end
  end
  
end
