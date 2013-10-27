# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Serializers::MARC do

  context 'when serializing a single document' do
    before(:each) do
      @doc = FactoryGirl.build(:full_document)
      @record = @doc.to_marc
    end

    it 'creates a good MARC::Record' do
      # Control fields
      expect(@record['001'].value).to eq('00972c5123877961056b21aea4177d0dc69c7318')
      expect(@record['003'].value).to eq('PDFSHASUM')
      expect(@record['008'].value).to eq('110501s2008       ||||fo     ||0 0|eng d')
      expect(@record['040']['a']).to eq('RLetters')
      expect(@record['040']['b']).to eq('eng')
      expect(@record['040']['c']).to eq('RLetters')

      # DOI field
      # Standard identifier type: stored in $2
      expect(@record['024'].indicator1).to eq('7')
      expect(@record['024']['2']).to eq('doi')
      expect(@record['024']['a']).to eq('10.1111/j.1439-0310.2008.01576.x')

      # First author field
      # Name is in Last, First format
      expect(@record['100'].indicator1).to eq('1')
      expect(@record['100']['a']).to eq('Botero, Carlos A.')

      # All author fields
      expected = ['Botero, Carlos A.', 'Mudge, Andrew E.', 'Koltz, Amanda M.',
                  'Hochachka, Wesley M.', 'Vehrencamp, Sandra L.']
      actual = []
      @record.select { |field| field.tag == '700' }.each do |f|
        # Name is in Last, First format
        expect(f.indicator1).to eq('1')
        actual << f['a']
      end
      expect(actual).to match_array(expected)

      # Title field
      # This is the entire title, no further information
      expect(@record['245'].indicator1).to eq('1')
      # This field ends with a period, even when other punctuation is
      # also present
      expect(@record['245']['a']).to eq('How Reliable are the Methods for Estimating Repertoire Size?.')

      # Journal, volume and/or number field
      # We also have an 830 entry to indicate the series
      expect(@record['490'].indicator1).to eq('1')
      expect(@record['490']['a']).to eq('Ethology')
      expect(@record['490']['v']).to eq('v. 114')
      # Don't guess at non-filing characters
      expect(@record['830'].indicator2).to eq('0')
      expect(@record['830']['a']).to eq('Ethology')
      expect(@record['830']['v']).to eq('v. 114')

      # "Host Item Entry" field (free-form citation data)
      # Do display this connection
      expect(@record['773'].indicator1).to eq('0')
      expect(@record['773']['t']).to eq('Ethology')
      # The "related parts" entry, used for the full journal citation
      expect(@record['773']['g']).to eq('Vol. 114 (2008), p. 1227-1238')
      # An abbreviated form of the same
      expect(@record['773']['q']).to eq('114<1227')
      # Specify this is a serial, not a human name of any sort
      expect(@record['773']['7']).to eq('nnas')

      # Detailed date and sequence information
      # Volume
      expect(@record['363']['a']).to eq('114')
      # FIXME: What do we do in the case of not having a number?  Should the
      # start page be listed in 'b'?
      expect(@record['363']['c']).to eq('1227')
      expect(@record['363']['i']).to eq('2008')

      # Date record
      # Date is properly formatted
      expect(@record['362'].indicator1).to eq('0')
      # Always ends with a period, since we do not express date ranges
      expect(@record['362']['a']).to eq('2008.')
    end
  end

  context 'when serializing a document with no year' do
    before(:each) do
      @doc = FactoryGirl.build(:full_document, year: nil)
      @record = @doc.to_marc
    end

    it 'handles no-year documents correctly' do
      expect(@record['008'].value).to eq('110501s0000       ||||fo     ||0 0|eng d')
    end
  end

  context 'when serializing an array of documents' do
    before(:each) do
      doc = FactoryGirl.build(:full_document)
      @docs = [doc, doc]
    end

    it 'creates MARCXML collections of the right size' do
      expect(@docs.to_marc_xml.css('collection').children.to_a).to have(2).elements
    end
  end

end
