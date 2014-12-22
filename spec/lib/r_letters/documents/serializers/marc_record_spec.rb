# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Documents::Serializers::MARCRecord do

  context 'when serializing a single document' do
    before(:example) do
      @doc = build(:full_document)
      @record = described_class.new(@doc).serialize
    end

    it 'creates a good MARC::Record' do
      # Control fields
      expect(@record['001'].value).to eq('doi:10.5678/dickens')
      expect(@record['003'].value).to eq('RLID')
      expect(@record['008'].value).to eq('110501s1859       ||||fo     ||0 0|eng d')
      expect(@record['040']['a']).to eq('RLetters')
      expect(@record['040']['b']).to eq('eng')
      expect(@record['040']['c']).to eq('RLetters')

      # DOI field
      # Standard identifier type: stored in $2
      expect(@record['024'].indicator1).to eq('7')
      expect(@record['024']['2']).to eq('doi')
      expect(@record['024']['a']).to eq('10.5678/dickens')

      # First author field
      # Name is in Last, First format
      expect(@record['100'].indicator1).to eq('1')
      expect(@record['100']['a']).to eq('Dickens, C.')

      # All author fields
      expected = ['Dickens, C.']
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
      expect(@record['245']['a']).to eq('A Tale of Two Cities.')

      # Journal, volume and/or number field
      # We also have an 830 entry to indicate the series
      expect(@record['490'].indicator1).to eq('1')
      expect(@record['490']['a']).to eq('Actually a Novel')
      expect(@record['490']['v']).to eq('v. 1 no. 1')
      # Don't guess at non-filing characters
      expect(@record['830'].indicator2).to eq('0')
      expect(@record['830']['a']).to eq('Actually a Novel')
      expect(@record['830']['v']).to eq('v. 1 no. 1')

      # "Host Item Entry" field (free-form citation data)
      # Do display this connection
      expect(@record['773'].indicator1).to eq('0')
      expect(@record['773']['t']).to eq('Actually a Novel')
      # The "related parts" entry, used for the full journal citation
      expect(@record['773']['g']).to eq('Vol. 1, no. 1 (1859), p. 1')
      # An abbreviated form of the same
      expect(@record['773']['q']).to eq('1:1<1')
      # Specify this is a serial, not a human name of any sort
      expect(@record['773']['7']).to eq('nnas')

      # Detailed date and sequence information
      # Volume
      expect(@record['363']['a']).to eq('1')
      # FIXME: What do we do in the case of not having a number?  Should the
      # start page be listed in 'b'?
      expect(@record['363']['b']).to eq('1')
      expect(@record['363']['c']).to eq('1')
      expect(@record['363']['i']).to eq('1859')

      # Date record
      # Date is properly formatted
      expect(@record['362'].indicator1).to eq('0')
      # Always ends with a period, since we do not express date ranges
      expect(@record['362']['a']).to eq('1859.')
    end
  end

  context 'when serializing a document with no year' do
    before(:example) do
      @doc = build(:full_document, year: nil)
      @record = described_class.new(@doc).serialize
    end

    it 'handles no-year documents correctly' do
      expect(@record['008'].value).to eq('110501s0000       ||||fo     ||0 0|eng d')
    end
  end

end
