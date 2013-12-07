# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Documents::Serializers::BibTex do

  context 'when serializing a single document' do
    before(:each) do
      @doc = FactoryGirl.build(:full_document)
      @str = @doc.to_bibtex
    end

    it 'creates good BibTeX' do
      expect(@str).to be_start_with('@article{Botero2008,')
      expect(@str).to include('author = {Carlos A. Botero and Andrew E. Mudge and Amanda M. Koltz and Wesley M. Hochachka and Sandra L. Vehrencamp}')
      expect(@str).to include('title = {How Reliable are the Methods for Estimating Repertoire Size?}')
      expect(@str).to include('journal = {Ethology}')
      expect(@str).to include('volume = {114}')
      expect(@str).to include('pages = {1227-1238}')
      expect(@str).to include('doi = {10.1111/j.1439-0310.2008.01576.x}')
      expect(@str).to include('year = {2008}')
    end
  end

  context 'when serializing an array of documents' do
    before(:each) do
      doc = FactoryGirl.build(:full_document)
      @docs = [doc, doc]
      @str = @docs.to_bibtex
    end

    it 'creates good BibTeX' do
      expect(@str).to be_start_with('@article{Botero2008,')
      expect(@str).to include("}\n@article{Botero2008,")
    end
  end

  context 'when serializing an anonymous document' do
    before(:each) do
      @doc = FactoryGirl.build(:full_document, authors: nil)
      @str = @doc.to_bibtex
    end

    it 'creates cite keys correctly' do
      expect(@str).to be_start_with('@article{Anon2008,')
    end
  end
end
