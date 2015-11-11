require 'rails_helper'

RSpec.describe RLetters::Documents::Serializers::MARCXML do
  context 'when serializing an array of documents' do
    before(:example) do
      doc = build(:full_document)
      @docs = [doc, doc]
      @xml = Nokogiri::XML::Document.parse(described_class.new(@docs).serialize)
    end

    it 'creates MARCXML collections of the right size' do
      expect(@xml.css('collection record').size).to eq(2)
    end

    it 'creates a good MARC::Record' do
      rec = @xml.css('collection record').first

      # Control fields
      expect(rec.css('controlfield[tag="001"]').text).to eq('doi:10.5678/dickens')
      expect(rec.css('controlfield[tag="003"]').text).to eq('RLID')
      expect(rec.css('controlfield[tag="008"]').text).to eq('110501s1859       ||||fo     ||0 0|eng d')
      expect(rec.css('datafield[tag="040"] subfield[code="a"]').text).to eq('RLetters')
      expect(rec.css('datafield[tag="040"] subfield[code="b"]').text).to eq('eng')
      expect(rec.css('datafield[tag="040"] subfield[code="c"]').text).to eq('RLetters')

      # DOI field
      # Standard identifier type: stored in $2
      expect(rec.css('datafield[tag="024"]')[0]['ind1']).to eq('7')
      expect(rec.css('datafield[tag="024"] subfield[code="2"]').text).to eq('doi')
      expect(rec.css('datafield[tag="024"] subfield[code="a"]').text).to eq('10.5678/dickens')

      # First author field
      # Name is in Last, First format
      expect(rec.css('datafield[tag="100"]')[0]['ind1']).to eq('1')
      expect(rec.css('datafield[tag="100"] subfield[code="a"]').text).to eq('Dickens, C.')

      # All author fields
      expected = ['Dickens, C.']
      actual = []
      rec.css('datafield[tag="700"]').each do |tag|
        # Name is in Last, First format
        expect(tag['ind1']).to eq('1')
        actual << tag.css('subfield[code="a"]').text
      end
      expect(actual).to match_array(expected)

      # Title field
      # This is the entire title, no further information
      expect(rec.css('datafield[tag="245"]')[0]['ind1']).to eq('1')
      # This field ends with a period, even when other punctuation is
      # also present
      expect(rec.css('datafield[tag="245"] subfield[code="a"]').text).to eq('A Tale of Two Cities.')

      # Journal, volume and/or number field
      # We also have an 830 entry to indicate the series
      expect(rec.css('datafield[tag="490"]')[0]['ind1']).to eq('1')
      expect(rec.css('datafield[tag="490"] subfield[code="a"]').text).to eq('Actually a Novel')
      expect(rec.css('datafield[tag="490"] subfield[code="v"]').text).to eq('v. 1 no. 1')
      # Don't guess at non-filing characters
      expect(rec.css('datafield[tag="830"]')[0]['ind2']).to eq('0')
      expect(rec.css('datafield[tag="830"] subfield[code="a"]').text).to eq('Actually a Novel')
      expect(rec.css('datafield[tag="830"] subfield[code="v"]').text).to eq('v. 1 no. 1')

      # "Host Item Entry" field (free-form citation data)
      # Do display this connection
      expect(rec.css('datafield[tag="773"]')[0]['ind1']).to eq('0')
      expect(rec.css('datafield[tag="773"] subfield[code="t"]').text).to eq('Actually a Novel')
      # The "related parts" entry, used for the full journal citation
      expect(rec.css('datafield[tag="773"] subfield[code="g"]').text).to eq('Vol. 1, no. 1 (1859), p. 1')
      # An abbreviated form of the same
      expect(rec.css('datafield[tag="773"] subfield[code="q"]').text).to eq('1:1<1')
      # Specify this is a serial, not a human name of any sort
      expect(rec.css('datafield[tag="773"] subfield[code="7"]').text).to eq('nnas')

      # Detailed date and sequence information
      # Volume
      expect(rec.css('datafield[tag="363"] subfield[code="a"]').text).to eq('1')
      # FIXME: What do we do in the case of not having a number?  Should the
      # start page be listed in 'b'?
      expect(rec.css('datafield[tag="363"] subfield[code="b"]').text).to eq('1')
      expect(rec.css('datafield[tag="363"] subfield[code="c"]').text).to eq('1')
      expect(rec.css('datafield[tag="363"] subfield[code="i"]').text).to eq('1859')

      # Date record
      # Date is properly formatted
      expect(rec.css('datafield[tag="362"]')[0]['ind1']).to eq('0')
      # Always ends with a period, since we do not express date ranges
      expect(rec.css('datafield[tag="362"] subfield[code="a"]').text).to eq('1859.')
    end
  end

  context 'when serializing a document with no year' do
    before(:example) do
      @doc = build(:full_document, year: nil)
      @xml = Nokogiri::XML::Document.parse(described_class.new(@doc).serialize)
    end

    it 'handles no-year documents correctly' do
      rec = @xml.css('record').first

      expect(rec.css('controlfield[tag="008"]').text).to eq('110501s0000       ||||fo     ||0 0|eng d')
    end
  end
end
