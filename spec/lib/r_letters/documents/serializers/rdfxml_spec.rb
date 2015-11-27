require 'rails_helper'

RSpec.describe RLetters::Documents::Serializers::RDFXML do
  context 'with a single document' do
    before(:example) do
      @doc = build(:full_document)
      @xml = Nokogiri::XML::Document.parse(described_class.new(@doc).serialize)
    end

    it 'creates an rdf root element' do
      expect(@xml.root.name).to eq('rdf')
    end

    it 'includes a single description element' do
      expect(@xml.css('Description').size).to eq(1)
    end

    it 'includes the Dublin Core elements' do
      expect(@xml.at_css('dc|title').content).to eq(@doc.title)
      expect(@xml.at_css('dc|relation').content).to eq(@doc.journal)
      expect(@xml.at_css('dc|issued').content).to eq(@doc.year.to_s)
      expect(@xml.at_css('dc|type').content).to eq('Journal Article')
      expect(@xml.at_css('dc|identifier').content).to eq('info:doi/10.5678/dickens')
    end

    it 'includes the authors' do
      tags = @xml.css('dc|creator')
      expect(tags.size).to eq(1)

      expect(tags.map(&:content)).to match_array(['Dickens, C.'])
    end

    it 'includes the citation elements' do
      expected = [
        '&ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3A' \
        'mtx%3Ajournal&rft.genre=article&' \
        'rft_id=info:doi%2F10.5678%2Fdickens&' \
        'rft.atitle=A+Tale+of+Two+Cities&rft.title=Actually+a+Novel&' \
        'rft.date=1859&rft.volume=1&rft.issue=1&rft.spage=1&rft.aufirst=C.&' \
        'rft.aulast=Dickens', 'Actually a Novel 1(1), 1. (1859)']

      citations = @xml.css('dc|bibliographicCitation')
      expect(citations.size).to eq(2)

      expect(citations.map(&:content)).to match_array(expected)
    end
  end

  context 'with an array of documents' do
    before(:example) do
      doc = build(:full_document)
      doc2 = build(:full_document, uid: 'doi:10.5678/otherdickens')

      @docs = [doc, doc2]
      @xml = Nokogiri::XML::Document.parse(described_class.new(@docs).serialize)
    end

    it 'includes two description elements' do
      expect(@xml.css('Description').size).to eq(2)
    end
  end
end
