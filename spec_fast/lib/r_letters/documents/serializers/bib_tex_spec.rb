# -*- encoding : utf-8 -*-
require 'r_letters/documents/serializers/bib_tex'
require 'support/doubles/document_basic'

describe RLetters::Documents::Serializers::BibTex do

  context 'when serializing a single document' do
    before(:each) do
      @doc = double_document_basic
      @str = described_class.new(@doc).serialize
    end

    it 'creates good BibTeX' do
      expect(@str).to be_start_with('@article{One2010,')
      expect(@str).to include('author = {A. One and B. Two}')
      expect(@str).to include('title = {Test Title}')
      expect(@str).to include('journal = {Journal}')
      expect(@str).to include('volume = {10}')
      expect(@str).to include('number = {20}')
      expect(@str).to include('pages = {100-200}')
      expect(@str).to include('doi = {10.1234/5678}')
      expect(@str).to include('year = {2010}')
    end
  end

  context 'when serializing an array of documents' do
    before(:each) do
      doc = double_document_basic
      @docs = [doc, doc]
      @str = described_class.new(@docs).serialize
    end

    it 'creates good BibTeX' do
      expect(@str).to be_start_with('@article{One2010,')
      expect(@str).to include("}\n@article{One2010,")
    end
  end

  context 'when serializing an anonymous document' do
    before(:each) do
      @doc = double_document_basic(authors: [])
      @str = described_class.new(@doc).serialize
    end

    it 'creates cite keys correctly' do
      expect(@str).to be_start_with('@article{Anon2010,')
    end
  end
end
