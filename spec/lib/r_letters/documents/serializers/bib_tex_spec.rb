require 'spec_helper'

RSpec.describe RLetters::Documents::Serializers::BibTex do
  context 'when serializing a single document' do
    before(:example) do
      @doc = build(:full_document)
      @str = described_class.new(@doc).serialize
    end

    it 'creates good BibTeX' do
      expect(@str).to start_with('@article{Dickens1859,')
      expect(@str).to include('author = {C. Dickens}')
      expect(@str).to include('title = {A Tale of Two Cities}')
      expect(@str).to include('journal = {Actually a Novel}')
      expect(@str).to include('volume = {1}')
      expect(@str).to include('number = {1}')
      expect(@str).to include('pages = {1}')
      expect(@str).to include('doi = {10.5678/dickens}')
      expect(@str).to include('year = {1859}')
    end
  end

  context 'when serializing an array of documents' do
    before(:example) do
      doc = build(:full_document)
      @docs = [doc, doc]
      @str = described_class.new(@docs).serialize
    end

    it 'creates good BibTeX' do
      expect(@str).to start_with('@article{Dickens1859,')
      expect(@str).to include("}\n@article{Dickens1859,")
    end
  end

  context 'when serializing an anonymous document' do
    before(:example) do
      @doc = build(:full_document, authors: nil)
      @str = described_class.new(@doc).serialize
    end

    it 'creates cite keys correctly' do
      expect(@str).to start_with('@article{Anon1859,')
    end
  end
end
