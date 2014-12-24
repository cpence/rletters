require 'spec_helper'
require 'nokogiri'

RSpec.describe RLetters::Documents::Serializers::MODS do
  before(:example) do
    spec_fast_dir = File.dirname(File.dirname(File.dirname(File.dirname(File.dirname(__FILE__)))))
    @mods_schema_path = File.join(spec_fast_dir, 'support', 'xsd', 'mods-3-4.xsd')
    @mods_schema = Nokogiri::XML::Schema.new(File.open(@mods_schema_path))
  end

  context 'when serializing a single document' do
    before(:example) do
      @doc = build(:full_document, pages: '123-456')
      @xml = Nokogiri::XML::Document.parse(described_class.new(@doc).serialize)
    end

    it 'creates good MODS documents' do
      # This test is incomplete, but we'll validate the schema in the next test
      expect(@xml.at_css('mods titleInfo title').content).to eq('A Tale of Two Cities')
      expect(@xml.at_css('mods name namePart').content).to eq('C.')
      expect(@xml.at_css('mods originInfo dateIssued').content).to eq('1859')
      expect(@xml.at_css('mods relatedItem titleInfo title').content).to eq('Actually a Novel')
      expect(@xml.at_css('mods relatedItem originInfo dateIssued').content).to eq('1859')
      expect(@xml.at_css('mods relatedItem part detail number:contains("1")')).to be
      expect(@xml.at_css('mods relatedItem part detail number:contains("1")')).to be
      expect(@xml.at_css('mods relatedItem part extent start').content).to eq('123')
      expect(@xml.at_css('mods relatedItem part extent end').content).to eq('456')
      expect(@xml.at_css('mods relatedItem part date').content).to eq('1859')
      expect(@xml.at_css('mods identifier').content).to eq('10.5678/dickens')
    end

    it 'creates MODS documents that are valid against the schema' do
      errors = @mods_schema.validate(@xml)
      fail(errors.map(&:to_s).join('; ')) if errors.length != 0
    end
  end

  context 'when serializing an array of documents' do
    before(:example) do
      doc = build(:full_document)
      doc2 = build(:full_document, uid: 'doi:10.5678/dickens2')

      @docs = [doc, doc2]
      @xml = Nokogiri::XML::Document.parse(described_class.new(@docs).serialize)
    end

    it 'creates good MODS collections' do
      expect(@xml.at_css('modsCollection mods titleInfo title').content).to eq('A Tale of Two Cities')
      expect(@xml.css('modsCollection mods').size).to eq(2)
    end

    it 'creates MODS collections that are valid against the schema' do
      errors = @mods_schema.validate(@xml)
      fail(errors.map(&:to_s).join('; ')) if errors.length != 0
    end
  end
end
