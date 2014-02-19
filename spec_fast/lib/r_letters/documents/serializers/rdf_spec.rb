# -*- encoding : utf-8 -*-
require 'r_letters/documents/serializers/rdf'
require 'support/doubles/document_basic'

describe RLetters::Documents::Serializers::RDF do

  context 'when serializing a single document' do
    before(:each) do
      @doc = double_document_basic
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

      expect(rdf_docs[0].journal.to_s).to eq('Journal')
      expect(rdf_docs[0].year.to_s).to eq('2010')
      expect(rdf_docs[0].title.to_s).to eq('Test Title')
      expect(rdf_docs[0].doistr.to_s).to eq('info:doi/10.1234/5678')

      rdf_authors = RDF::Query.execute(
        @graph,
        doc: {
          RDF::DC.type => 'Journal Article',
          RDF::DC.creator => :author
        })

      expect(rdf_authors.size).to eq(2)

      expected = ['One, A.', 'Two, B.']
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

      expected = ['&ctx_ver=Z39.88-2004' \
                  '&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3A' \
                  'mtx%3Ajournal&rft.genre=article' \
                  '&rft_id=info:doi%2F10.1234%2F5678' \
                  '&rft.atitle=Test+Title' \
                  '&rft.title=Journal&rft.date=2010' \
                  '&rft.volume=10&rft.issue=20' \
                  '&rft.spage=100&rft.epage=200' \
                  '&rft.aufirst=A.&rft.aulast=One' \
                  '&rft.au=B.+Two',
                  'Journal 10(20), 100-200. (2010)']

      actual = []
      rdf_citations.each do |d|
        actual << d.citation.to_s
      end
      expect(actual).to match_array(expected)
    end
  end

end
