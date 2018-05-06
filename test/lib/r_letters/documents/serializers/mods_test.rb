# frozen_string_literal: true
require 'test_helper'
require_relative './common_tests'

class RLetters::Documents::Serializers::MODSTest < ActiveSupport::TestCase
  include RLetters::Documents::Serializers::CommonTests

  test 'single document serialization' do
    doc = build(:full_document, pages: '123-456')
    raw = RLetters::Documents::Serializers::MODS.new(doc).serialize
    xml = Nokogiri::XML::Document.parse(raw)

    # This test is incomplete, but we'll validate the schema in the next test
    assert_equal 'A Tale of Two Cities', xml.at_css('mods titleInfo title').content
    assert_equal 'C.', xml.at_css('mods name namePart').content
    assert_equal '1859', xml.at_css('mods originInfo dateIssued').content
    assert_equal 'Actually a Novel', xml.at_css('mods relatedItem titleInfo title').content
    assert_equal '1859', xml.at_css('mods relatedItem originInfo dateIssued').content
    refute_nil xml.at_css('mods relatedItem part detail number:contains("1")')
    refute_nil xml.at_css('mods relatedItem part detail number:contains("1")')
    assert_equal '123', xml.at_css('mods relatedItem part extent start').content
    assert_equal '456', xml.at_css('mods relatedItem part extent end').content
    assert_equal '1859', xml.at_css('mods relatedItem part date').content
    assert_equal '10.5678/dickens', xml.at_css('mods identifier').content
  end

  test 'single document schema validation' do
    doc = build(:full_document, pages: '123-456')
    raw = RLetters::Documents::Serializers::MODS.new(doc).serialize
    xml = Nokogiri::XML::Document.parse(raw)

    schema_path = File.expand_path('../../../../../support/xsd/mods-3-4.xsd',
                                   __FILE__)
    schema = Nokogiri::XML::Schema.new(File.open(schema_path))

    errors = schema.validate(xml)
    assert_empty errors, errors.map(&:to_s).join('; ')
  end

  test 'array serialization' do
    doc = build(:full_document)
    doc2 = build(:full_document, uid: 'doi:10.5678/dickens2')
    docs = [doc, doc2]
    raw = RLetters::Documents::Serializers::MODS.new(docs).serialize
    xml = Nokogiri::XML::Document.parse(raw)

    assert_equal 'A Tale of Two Cities', xml.at_css('modsCollection mods titleInfo title').content
    assert_equal 2, xml.css('modsCollection mods').size
  end

  test 'array schema validation' do
    doc = build(:full_document)
    doc2 = build(:full_document, uid: 'doi:10.5678/dickens2')
    docs = [doc, doc2]
    raw = RLetters::Documents::Serializers::MODS.new(docs).serialize
    xml = Nokogiri::XML::Document.parse(raw)

    schema_path = File.expand_path('../../../../../support/xsd/mods-3-4.xsd',
                                   __FILE__)
    schema = Nokogiri::XML::Schema.new(File.open(schema_path))

    errors = schema.validate(xml)
    assert_empty errors, errors.map(&:to_s).join('; ')
  end
end
