# -*- encoding : utf-8 -*-
require 'r_letters/documents/serializers/mods'
require 'support/doubles/document_basic'
require 'nokogiri'

describe RLetters::Documents::Serializers::MODS do
  before(:each) do
    spec_fast_dir = File.dirname(File.dirname(File.dirname(File.dirname(File.dirname(__FILE__)))))
    @mods_schema_path = File.join(spec_fast_dir, 'support', 'xsd', 'mods-3-4.xsd')
    @mods_schema = Nokogiri::XML::Schema.new(File.open(@mods_schema_path))
  end

  context 'when serializing a single document' do
    before(:each) do
      @doc = double_document_basic
      @xml = Nokogiri::XML::Document.parse(described_class.new(@doc).serialize)
    end

    it 'creates good MODS documents' do
      # This test is incomplete, but we'll validate the schema in the next test
      expect(@xml.at_css('mods titleInfo title').content).to eq('Test Title')
      expect(@xml.at_css('mods name namePart').content).to eq('A.')
      expect(@xml.at_css('mods originInfo dateIssued').content).to eq('2010')
      expect(@xml.at_css('mods relatedItem titleInfo title').content).to eq('Journal')
      expect(@xml.at_css('mods relatedItem originInfo dateIssued').content).to eq('2010')
      expect(@xml.at_css('mods relatedItem part detail number:contains("10")')).to be
      expect(@xml.at_css('mods relatedItem part detail number:contains("20")')).to be
      expect(@xml.at_css('mods relatedItem part extent start').content).to eq('100')
      expect(@xml.at_css('mods relatedItem part date').content).to eq('2010')
      expect(@xml.at_css('mods identifier').content).to eq('10.1234/5678')
    end

    it 'creates MODS documents that are valid against the schema' do
      errors = @mods_schema.validate(@xml)
      fail(errors.map { |e| e.to_s }.join('; ')) if errors.length != 0
    end
  end

  context 'when serializing an array of documents' do
    before(:each) do
      doc = double_document_basic
      doc2 = double_document_basic(uid: 'somethingelse',
                                   html_uid: 'somethingelse')

      @docs = [doc, doc2]
      @xml = Nokogiri::XML::Document.parse(described_class.new(@docs).serialize)
    end

    it 'creates good MODS collections' do
      expect(@xml.at_css('modsCollection mods titleInfo title').content).to eq('Test Title')
      expect(@xml.css('modsCollection mods').count).to eq(2)
    end

    it 'creates MODS collections that are valid against the schema' do
      errors = @mods_schema.validate(@xml)
      fail(errors.map { |e| e.to_s }.join('; ')) if errors.length != 0
    end
  end

end
