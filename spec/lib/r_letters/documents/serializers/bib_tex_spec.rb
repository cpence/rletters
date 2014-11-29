# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Documents::Serializers::BibTex do

  context 'when serializing a single document' do
    before(:example) do
      @doc = build(:full_document)
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
    before(:example) do
      doc = build(:full_document)
      @docs = [doc, doc]
      @str = described_class.new(@docs).serialize
    end

    it 'creates good BibTeX' do
      expect(@str).to be_start_with('@article{One2010,')
      expect(@str).to include("}\n@article{One2010,")
    end
  end

  context 'when serializing an anonymous document' do
    before(:example) do
      @doc = build(:full_document, authors: nil)
      @str = described_class.new(@doc).serialize
    end

    it 'creates cite keys correctly' do
      expect(@str).to be_start_with('@article{Anon2010,')
    end
  end
end
