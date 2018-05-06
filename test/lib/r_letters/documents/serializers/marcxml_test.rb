# frozen_string_literal: true
require 'test_helper'
require_relative './common_tests'

class RLetters::Documents::Serializers::MARCXMLTest < ActiveSupport::TestCase
  include RLetters::Documents::Serializers::CommonTests

  test 'array serialization' do
    doc = build(:full_document)
    docs = [doc, doc]
    raw = RLetters::Documents::Serializers::MARCXML.new(docs).serialize
    xml = Nokogiri::XML::Document.parse(raw)

    assert_equal 2, xml.css('collection record').size

    rec = xml.css('collection record').first

    # Control fields
    assert_equal 'doi:10.5678/dickens', rec.css('controlfield[tag="001"]').text
    assert_equal 'RLID', rec.css('controlfield[tag="003"]').text
    assert_equal '110501s1859       ||||fo     ||0 0|eng d', rec.css('controlfield[tag="008"]').text
    assert_equal 'RLetters', rec.css('datafield[tag="040"] subfield[code="a"]').text
    assert_equal 'eng', rec.css('datafield[tag="040"] subfield[code="b"]').text
    assert_equal 'RLetters', rec.css('datafield[tag="040"] subfield[code="c"]').text

    # DOI field
    # Standard identifier type: stored in $2
    assert_equal '7', rec.css('datafield[tag="024"]')[0]['ind1']
    assert_equal 'doi', rec.css('datafield[tag="024"] subfield[code="2"]').text
    assert_equal '10.5678/dickens', rec.css('datafield[tag="024"] subfield[code="a"]').text

    # First author field
    # Name is in Last, First format
    assert_equal '1', rec.css('datafield[tag="100"]')[0]['ind1']
    assert_equal 'Dickens, C.', rec.css('datafield[tag="100"] subfield[code="a"]').text

    # All author fields
    expected = ['Dickens, C.']
    actual = []
    rec.css('datafield[tag="700"]').each do |tag|
      # Name is in Last, First format
      assert_equal '1', tag['ind1']
      actual << tag.css('subfield[code="a"]').text
    end
    assert_equal expected.sort, actual.sort

    # Title field
    # This is the entire title, no further information
    assert_equal '1', rec.css('datafield[tag="245"]')[0]['ind1']
    # This field ends with a period, even when other punctuation is
    # also present
    assert_equal 'A Tale of Two Cities.', rec.css('datafield[tag="245"] subfield[code="a"]').text

    # Journal, volume and/or number field
    # We also have an 830 entry to indicate the series
    assert_equal '1', rec.css('datafield[tag="490"]')[0]['ind1']
    assert_equal 'Actually a Novel', rec.css('datafield[tag="490"] subfield[code="a"]').text
    assert_equal 'v. 1 no. 1', rec.css('datafield[tag="490"] subfield[code="v"]').text
    # Don't guess at non-filing characters
    assert_equal '0', rec.css('datafield[tag="830"]')[0]['ind2']
    assert_equal 'Actually a Novel', rec.css('datafield[tag="830"] subfield[code="a"]').text
    assert_equal 'v. 1 no. 1', rec.css('datafield[tag="830"] subfield[code="v"]').text

    # "Host Item Entry" field (free-form citation data)
    # Do display this connection
    assert_equal '0', rec.css('datafield[tag="773"]')[0]['ind1']
    assert_equal 'Actually a Novel', rec.css('datafield[tag="773"] subfield[code="t"]').text
    # The "related parts" entry, used for the full journal citation
    assert_equal 'Vol. 1, no. 1 (1859), p. 1', rec.css('datafield[tag="773"] subfield[code="g"]').text
    # An abbreviated form of the same
    assert_equal '1:1<1', rec.css('datafield[tag="773"] subfield[code="q"]').text
    # Specify this is a serial, not a human name of any sort
    assert_equal 'nnas', rec.css('datafield[tag="773"] subfield[code="7"]').text

    # Detailed date and sequence information
    # Volume
    assert_equal '1', rec.css('datafield[tag="363"] subfield[code="a"]').text
    # FIXME: What do we do in the case of not having a number?  Should the
    # start page be listed in 'b'?
    assert_equal '1', rec.css('datafield[tag="363"] subfield[code="b"]').text
    assert_equal '1', rec.css('datafield[tag="363"] subfield[code="c"]').text
    assert_equal '1859', rec.css('datafield[tag="363"] subfield[code="i"]').text

    # Date record
    # Date is properly formatted
    assert_equal '0', rec.css('datafield[tag="362"]')[0]['ind1']
    # Always ends with a period, since we do not express date ranges
    assert_equal '1859.', rec.css('datafield[tag="362"] subfield[code="a"]').text
  end

  test 'works when documents have no year' do
    doc = build(:full_document, year: nil)
    raw = RLetters::Documents::Serializers::MARCXML.new(doc).serialize
    xml = Nokogiri::XML::Document.parse(raw)

    rec = xml.css('record').first

    assert_equal '110501s0000       ||||fo     ||0 0|eng d', rec.css('controlfield[tag="008"]').text
  end
end
