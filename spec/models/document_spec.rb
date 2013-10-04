# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Document do
  it_should_behave_like 'ActiveModel'

  describe '#valid' do
    context 'when no shasum is specified' do
      before(:each) do
        @doc = FactoryGirl.build(:document, shasum: nil)
      end

      it 'is not valid' do
        expect(@doc).not_to be_valid
      end
    end

    context 'when a short shasum is specified' do
      before(:each) do
        @doc = FactoryGirl.build(:document, shasum: 'notanshasum')
      end

      it 'is not valid' do
        expect(@doc).not_to be_valid
      end
    end

    context 'when a bad shasum is specified' do
      before(:each) do
        @doc = FactoryGirl.build(:document, shasum: '1234567890thisisbad!')
      end

      it 'is not valid' do
        expect(@doc).not_to be_valid
      end
    end

    context 'when a good shasum is specified' do
      before(:each) do
        @doc = FactoryGirl.build(:document)
      end

      it 'is valid' do
        expect(@doc).to be_valid
      end
    end
  end

  describe '.find' do
    context 'when loading one document',
            vcr: { cassette_name: 'solr_single' } do
      before(:each) do
        @doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
      end

      it 'loads the document successfully' do
        expect(@doc).to be
      end
    end

    context 'when no documents are returned',
            vcr: { cassette_name: 'solr_fail' } do
      it 'raises an exception' do
        expect { Document.find('fail') }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when Solr times out' do
      it 'raises an exception' do
        stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
        expect { Document.find('fail') }.to raise_error(StandardError)
      end
    end
  end

  describe '.find_by_shasum' do
    context 'when loading one document',
            vcr: { cassette_name: 'solr_single' } do
      before(:each) do
        @doc = Document.find_by_shasum('00972c5123877961056b21aea4177d0dc69c7318')
      end

      it 'loads the document successfully' do
        expect(@doc).to be
      end
    end

    context 'when no documents are returned',
            vcr: { cassette_name: 'solr_fail' } do
      it 'does not raise an exception' do
        expect { Document.find_by_shasum('fail') }.to_not raise_error
      end

      it 'returns nil' do
        expect(Document.find_by_shasum('fail')).to be_nil
      end
    end
  end

  describe '.find_with_fulltext' do
    context 'when loading one document with fulltext',
            vcr: { cassette_name: 'solr_single_fulltext' } do
      before(:each) do
        @doc = Document.find_with_fulltext('00972c5123877961056b21aea4177d0dc69c7318')
      end

      it 'loads the document successfully' do
        expect(@doc).to be
      end
    end

    context 'when no documents are returned',
            vcr: { cassette_name: 'solr_fail_fulltext' } do
      it 'raises an exception' do
        expect { Document.find_with_fulltext('fail') }.to raise_error(StandardError)
      end
    end

    context 'when Solr times out' do
      it 'raises an exception' do
        stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
        expect { Document.find_with_fulltext('fail') }.to raise_error(StandardError)
      end
    end
  end

    describe '.find_by_shasum_with_fulltext' do
    context 'when loading one document with fulltext',
            vcr: { cassette_name: 'solr_single_fulltext' } do
      before(:each) do
        @doc = Document.find_by_shasum_with_fulltext('00972c5123877961056b21aea4177d0dc69c7318')
      end

      it 'loads the document successfully' do
        expect(@doc).to be
      end
    end

    context 'when no documents are returned',
            vcr: { cassette_name: 'solr_fail_fulltext' } do
      it 'does not raise an exception' do
        expect { Document.find_by_shasum_with_fulltext('fail') }.to_not raise_error
      end

      it 'returns nil' do
        expect(Document.find_by_shasum_with_fulltext('fail')).to be_nil
      end
    end
  end

  # All of these attributes are loaded in the same loop, so they can be
  # tested at the same time
  describe 'attributes' do
    context 'when loading one document',
            vcr: { cassette_name: 'solr_single' } do
      before(:each) do
        @doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
      end

      it 'gets the right shasum' do
        expect(@doc.shasum).to eq('00972c5123877961056b21aea4177d0dc69c7318')
      end

      it 'does not have any fulltext' do
        expect(@doc.fulltext).to be_nil
      end
    end

    context 'when loading one document with fulltext',
            vcr: { cassette_name: 'solr_single_fulltext' } do
      before(:each) do
        @doc = Document.find_with_fulltext('00972c5123877961056b21aea4177d0dc69c7318')
      end

      it 'gets the right shasum' do
        expect(@doc.shasum).to eq('00972c5123877961056b21aea4177d0dc69c7318')
      end

      it 'loads the fulltext' do
        expect(@doc.fulltext).to be
      end
    end

    context 'when loading a set of documents',
            vcr: { cassette_name: 'solr_default' } do
      before(:each) do
        @result = Solr::Connection.search({ q: '*:*', defType: 'lucene' })
        @docs = @result.documents
      end

      it 'sets the shasum' do
        expect(@docs[0].shasum).to eq('2aed42dcdf4d98ee499a1d19b4a0d613b5377ad0')
      end

      it 'sets the doi' do
        expect(@docs[3].doi).to eq('10.1111/j.1439-0310.2006.01156.x')
      end

      it 'sets the license' do
        expect(@docs[0].license).to eq('© Blackwell Verlag GmbH')
      end

      it 'does not set the license URL (none specified)' do
        expect(@docs[2].license_url).not_to be
      end

      it 'sets the authors' do
        expect(@docs[9].authors).to eq('C. Alaux, Y. Le Conte, H. A. Adams, S. Rodriguez-Zas, C. M. Grozinger, S. Sinha, G. E. Robinson')
      end

      it 'sets the title' do
        expect(@docs[2].title).to eq('Fine mapping of a sedative-hypnotic drug withdrawal locus on mouse chromosome 11')
      end

      it 'sets the journal' do
        expect(@docs[0].journal).to eq('Ethology')
      end

      it 'sets the year' do
        expect(@docs[5].year).to eq('2009')
      end

      it 'sets the volume' do
        expect(@docs[7].volume).to eq('6')
      end

      it 'sets the pages' do
        expect(@docs[8].pages).to eq('581-591')
      end

      it 'does not set the fulltext' do
        expect(@docs[1].fulltext).to be_nil
      end
    end
  end

  describe '#author_list' do
    context 'when loading one document',
            vcr: { cassette_name: 'solr_single' } do
      before(:each) do
        @doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
      end

      it 'gets the right number of authors' do
        expect(@doc.author_list).to have(5).items
      end

      it 'gets the right first author' do
        expect(@doc.author_list[0]).to eq('Carlos A. Botero')
      end

      it 'gets the right fourth author' do
        expect(@doc.author_list[3]).to eq('Wesley M. Hochachka')
      end
    end
  end

  describe '#formatted_author_list' do
    context 'when loading one document',
            vcr: { cassette_name: 'solr_single' } do
      before(:each) do
        @doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
      end

      it 'gets the right number of authors' do
        expect(@doc.formatted_author_list).to have(5).items
      end

      it 'gets the right second author, first name' do
        expect(@doc.formatted_author_list[1].first).to eq('Andrew E.')
      end

      it 'gets the right fifth author, last name' do
        expect(@doc.formatted_author_list[4].last).to eq('Vehrencamp')
      end
    end
  end

  describe '#start_page and #end_page' do
    context 'when loading one document',
            vcr: { cassette_name: 'solr_single' } do
      before(:each) do
        @doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
      end

      it 'parses start_page correctly' do
        expect(@doc.start_page).to eq('1227')
      end

      it 'parses end_page correctly' do
        expect(@doc.end_page).to eq('1238')
      end
    end

    context 'when loading a document with funny page ranges' do
      before(:each) do
        @doc = FactoryGirl.build(:document, pages: '1483-92')
      end

      it 'parses start_page correctly' do
        expect(@doc.start_page).to eq('1483')
      end

      it 'parses end_page correctly' do
        expect(@doc.end_page).to eq('1492')
      end
    end
  end

  describe '#term_vectors' do
    context 'when loading one document',
            vcr: { cassette_name: 'solr_single' } do
      before(:each) do
        @doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
      end

      it 'does not set any term vectors' do
        expect(@doc.term_vectors).to be_nil
      end
    end

    context 'when loading one document with fulltext',
            vcr: { cassette_name: 'solr_single_fulltext' } do
      before(:each) do
        @doc = Document.find_with_fulltext('00972c5123877961056b21aea4177d0dc69c7318')
      end

      it 'sets the term vectors' do
        expect(@doc.term_vectors).to be
      end

      it 'sets tf' do
        expect(@doc.term_vectors['m'][:tf]).to eq(2)
      end

      it 'sets positions' do
        expect(@doc.term_vectors['center'][:positions][0]).to eq(26)
      end

      it 'sets df' do
        expect(@doc.term_vectors['reliable'][:df]).to eq(1.0)
      end

      it 'sets tfidf' do
        expect(@doc.term_vectors['andrew'][:tfidf]).to be_within(0.001).of(0.06666)
      end

      it 'does not set anything for terms that do not appear' do
        expect(@doc.term_vectors['zuzax']).not_to be
      end
    end

    context 'when loading one document with offsets',
            vcr: { cassette_name: 'solr_single_fulltext_offsets' } do
      before(:each) do
        @result = Solr::Connection.search(q: 'shasum:00972c5123877961056b21aea4177d0dc69c7318',
                                          defType: 'lucene',
                                          fields: Solr::Connection::DEFAULT_FIELDS_FULLTEXT,
                                          tv: 'true',
                                          'tv.offsets' => 'true')
        @doc = @result.documents[0]
      end

      it 'sets offsets' do
        expect(@doc.term_vectors['vehrencampf'][:offsets][0]).to eq(162...173)
      end
    end
  end

end
