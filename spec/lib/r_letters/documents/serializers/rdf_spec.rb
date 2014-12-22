# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Documents::Serializers::RDF do

  context 'when serializing a single document' do
    before(:example) do
      @doc = build(:full_document)
      @graph = described_class.new(@doc).serialize
    end

    it 'creates a good RDF graph' do
      rdf_docs = RDF::Query.execute(
        @graph,
        doc: {
          RDF::DC.type => 'Journal Article',
          RDF::DC.issued => :year,
          RDF::DC.relation => :journal,
          RDF::DC.title => :title,
          RDF::DC.identifier => :doistr
        })
      expect(rdf_docs.size).to eq(1)

      expect(rdf_docs[0].journal.to_s).to eq('Actually a Novel')
      expect(rdf_docs[0].year.to_s).to eq('1859')
      expect(rdf_docs[0].title.to_s).to eq('A Tale of Two Cities')
      expect(rdf_docs[0].doistr.to_s).to eq('info:doi/10.5678/dickens')

      rdf_authors = RDF::Query.execute(
        @graph,
        doc: {
          RDF::DC.type => 'Journal Article',
          RDF::DC.creator => :author
        })

      expect(rdf_authors.size).to eq(1)

      expected = ['Dickens, C.']
      actual = []
      rdf_authors.each do |d|
        actual << d.author.to_s
      end
      expect(actual).to match_array(expected)

      rdf_citations = RDF::Query.execute(
        @graph,
        doc: {
          RDF::DC.type => 'Journal Article',
          RDF::DC.bibliographicCitation => :citation
        })

      expect(rdf_citations.size).to eq(2)

      expected = [
        '&ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3A' \
        'mtx%3Ajournal&rft.genre=article&' \
        'rft_id=info:doi%2F10.5678%2Fdickens&' \
        'rft.atitle=A+Tale+of+Two+Cities&rft.title=Actually+a+Novel&' \
        'rft.date=1859&rft.volume=1&rft.issue=1&rft.spage=1&rft.aufirst=C.&' \
        'rft.aulast=Dickens', 'Actually a Novel 1(1), 1. (1859)']

      actual = []
      rdf_citations.each do |d|
        actual << d.citation.to_s
      end
      expect(actual).to match_array(expected)
    end
  end

end
