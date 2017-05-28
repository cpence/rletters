require 'test_helper'

# This tests both halves of the RDF serializers, the same code is generating
# the N3 representation, but this is easier to spec.
class RDFXMLTest < ActiveSupport::TestCase
  test 'class methods work' do
    assert_kind_of String, RLetters::Documents::Serializers::RDFXML.format
    assert_kind_of String, RLetters::Documents::Serializers::RDFXML.url
  end

  test 'single document serialization' do
    doc = build(:full_document)
    raw = RLetters::Documents::Serializers::RDFXML.new(doc).serialize
    xml = Nokogiri::XML::Document.parse(raw)

    assert_equal 'rdf', xml.root.name

    assert_equal 1, xml.css('Description').size

    assert_equal doc.title, xml.at_css('dc|title').content
    assert_equal doc.journal, xml.at_css('dc|relation').content
    assert_equal doc.year.to_s, xml.at_css('dc|issued').content
    assert_equal 'Journal Article', xml.at_css('dc|type').content
    assert_equal 'info:doi/10.5678/dickens', xml.at_css('dc|identifier').content

    tags = xml.css('dc|creator')
    assert_equal 1, tags.size
    assert_equal ['Dickens, C.'], tags.map(&:content)

    expected = [
      '&ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3A' \
      'mtx%3Ajournal&rft.genre=article&' \
      'rft_id=info:doi%2F10.5678%2Fdickens&' \
      'rft.atitle=A+Tale+of+Two+Cities&rft.title=Actually+a+Novel&' \
      'rft.date=1859&rft.volume=1&rft.issue=1&rft.spage=1&rft.aufirst=C.&' \
      'rft.aulast=Dickens', 'Actually a Novel 1(1), 1. (1859)']

    citations = xml.css('dc|bibliographicCitation')
    assert_equal 2, citations.size

    assert_equal expected.sort, citations.map(&:content).sort
  end

  test 'array serialization' do
    doc = build(:full_document)
    doc2 = build(:full_document, uid: 'doi:10.5678/otherdickens')
    docs = [doc, doc2]
    raw = RLetters::Documents::Serializers::RDFXML.new(docs).serialize
    xml = Nokogiri::XML::Document.parse(raw)

    assert_equal 2, xml.css('Description').size
  end
end
