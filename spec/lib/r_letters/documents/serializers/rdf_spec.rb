# -*- encoding : utf-8 -*-
require 'spec_helper'

describe RLetters::Documents::Serializers::RDF do

  context 'when serializing a single document' do
    before(:each) do
      @doc = FactoryGirl.build(:full_document)
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
      expect(rdf_docs.count).to eq(1)

      expect(rdf_docs[0].journal.to_s).to eq('Ethology')
      expect(rdf_docs[0].year.to_s).to eq('2008')
      expect(rdf_docs[0].title.to_s).to eq('How Reliable are the Methods for Estimating Repertoire Size?')
      expect(rdf_docs[0].doistr.to_s).to eq('info:doi/10.1111/j.1439-0310.2008.01576.x')

      rdf_authors = RDF::Query.execute(
        @graph,
        doc: {
          RDF::DC.type => 'Journal Article',
          RDF::DC.creator => :author
        })

      expect(rdf_authors.count).to eq(5)

      expected = ['Botero, Carlos A.', 'Mudge, Andrew E.', 'Koltz, Amanda M.',
                  'Hochachka, Wesley M.', 'Vehrencamp, Sandra L.']
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

      expect(rdf_citations.count).to eq(2)

      # rubocop:disable LineContinuation
      expected = ['&ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3A' \
                  'mtx%3Ajournal&rft.genre=article&' \
                  'rft_id=info:doi%2F10.1111%2Fj.1439-0310.2008.01576.x' \
                  '&rft.atitle=How+Reliable+are+the+Methods+for+' \
                  'Estimating+Repertoire+Size%3F' \
                  '&rft.title=Ethology&rft.date=2008&rft.volume=114' \
                  '&rft.spage=1227&rft.epage=1238&rft.aufirst=Carlos+A.' \
                  '&rft.aulast=Botero&rft.au=Andrew+E.+Mudge' \
                  '&rft.au=Amanda+M.+Koltz&rft.au=Wesley+M.+Hochachka' \
                  '&rft.au=Sandra+L.+Vehrencamp',
                  'Ethology 114, 1227-1238. (2008)']
      # rubocop:enable LineContinuation

      actual = []
      rdf_citations.each do |d|
        actual << d.citation.to_s
      end
      expect(actual).to match_array(expected)
    end
  end

end
