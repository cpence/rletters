# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Document do
  it_should_behave_like 'ActiveModel'

  describe '#valid' do
    context 'when no uid is specified' do
      before(:each) do
        @doc = FactoryGirl.build(:document, uid: nil)
      end

      it 'is not valid' do
        expect(@doc).not_to be_valid
      end
    end

    context 'when a good uid is specified' do
      before(:each) do
        @doc = FactoryGirl.build(:document)
      end

      it 'is valid' do
        expect(@doc).to be_valid
      end
    end
  end

  describe '.find' do
    context 'without fulltext' do
      context 'when loading one document' do
        before(:each) do
          @doc = Document.find('doi:10.1111/j.1439-0310.2008.01576.x')
        end

        it 'loads the document successfully' do
          expect(@doc).to be
        end
      end

      context 'when no documents are returned' do
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

    context 'with fulltext' do
      context 'when loading one document with fulltext' do
        before(:each) do
          @doc = Document.find('doi:10.1111/j.1439-0310.2008.01576.x', fulltext: true)
        end

        it 'loads the document successfully' do
          expect(@doc).to be
        end
      end

      context 'when no documents are returned' do
        it 'raises an exception' do
          expect { Document.find('fail', true) }.to raise_error(StandardError)
        end
      end

      context 'when Solr times out' do
        it 'raises an exception' do
          stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
          expect { Document.find('fail', true) }.to raise_error(StandardError)
        end
      end
    end

    context 'with external fulltext (HTTP)' do
      before(:each) do
        stub_connection('http://www.gutenberg.org/cache/epub/3172/pg3172.txt', 'gutenberg')
        @doc = Document.find('gutenberg:3172', fulltext: true, term_vectors: true)
      end

      it 'loads successfully' do
        expect(@doc).to be
      end

      it 'loads the fulltext' do
        expect(@doc.fulltext).to start_with('The Project Gutenberg EBook of')
      end

      it 'loads the term vectors' do
        expect(@doc.term_vectors).to be
      end

      it 'fills in term vectors with reasonable quantites' do
        expect(@doc.term_vectors['cooper']['tf']).to be(44)
      end
    end
  end

  describe '.find_by' do
    context 'without fulltext' do
      context 'when loading one document' do
        before(:each) do
          @doc = Document.find_by(uid: 'doi:10.1111/j.1439-0310.2008.01576.x')
        end

        it 'loads the document successfully' do
          expect(@doc).to be
        end
      end

      context 'when no documents are returned' do
        it 'does not raise an exception' do
          expect { Document.find_by(uid: 'fail') }.to_not raise_error
        end

        it 'returns nil' do
          expect(Document.find_by(uid: 'fail')).to be_nil
        end
      end

      context 'with a field other than uid' do
        before(:each) do
          @doc = Document.find_by(authors: 'C. Alaux')
        end

        it 'loads the document successfully' do
          expect(@doc).to be
        end
      end
    end

    context 'with fulltext' do
      context 'when loading one document with fulltext' do
        before(:each) do
          @doc = Document.find_by(uid: 'doi:10.1111/j.1439-0310.2008.01576.x', fulltext: true)
        end

        it 'loads the document successfully' do
          expect(@doc).to be
        end
      end

      context 'when no documents are returned' do
        it 'does not raise an exception' do
          expect { Document.find_by(uid: 'fail', fulltext: true) }.to_not raise_error
        end

        it 'returns nil' do
          expect(Document.find_by(uid: 'fail', fulltext: true)).to be_nil
        end
      end
    end
  end

  describe '.find_by!' do
    context 'when no documents are returned' do
      it 'raises an exception' do
        expect { Document.find_by!(uid: 'fail') }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when Solr times out' do
      it 'raises an exception' do
        stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
        expect { Document.find_by!(uid: 'fail') }.to raise_error(StandardError)
      end
    end
  end

  # All of these attributes are loaded in the same loop, so they can be
  # tested at the same time
  describe 'attributes' do
    context 'when loading one document' do
      before(:each) do
        @doc = Document.find('doi:10.1111/j.1439-0310.2008.01576.x')
      end

      it 'gets the right uid' do
        expect(@doc.uid).to eq('doi:10.1111/j.1439-0310.2008.01576.x')
      end

      it 'does not have any fulltext' do
        expect(@doc.fulltext).to be_nil
      end
    end

    context 'when loading one document with fulltext' do
      before(:each) do
        @doc = Document.find('doi:10.1111/j.1439-0310.2008.01576.x', fulltext: true)
      end

      it 'gets the right uid' do
        expect(@doc.uid).to eq('doi:10.1111/j.1439-0310.2008.01576.x')
      end

      it 'loads the fulltext' do
        expect(@doc.fulltext).to be
      end

      it 'does not load term vectors' do
        expect(@doc.term_vectors).not_to be
      end
    end

    context 'when loading a set of documents' do
      before(:each) do
        @result = Solr::Connection.search(q: '*:*', defType: 'lucene')
        @docs = @result.documents
      end

      it 'sets the uid' do
        expect(@docs[0].uid).to eq('doi:10.1111/j.1601-183X.2009.00525.x')
      end

      it 'sets the doi' do
        expect(@docs[3].doi).to eq('10.1111/j.1439-0310.2010.01811.x')
      end

      it 'sets the license' do
        expect(@docs[0].license).to eq('© Blackwell Publishing Ltd/International Behavioural and Neural Genetics Society')
      end

      it 'does not set the license URL (none specified)' do
        expect(@docs[2].license_url).not_to be
      end

      it 'sets the authors' do
        expect(@docs[9].authors).to eq('Christian T. Vlautin, Nicholas J. Hobbs, Michael H. Ferkin')
      end

      it 'sets the title' do
        expect(@docs[2].title).to eq('Defining the dopamine transporter proteome by convergent biochemical and in silico analyses')
      end

      it 'sets the journal' do
        expect(@docs[0].journal).to eq('Genes, Brain and Behavior')
      end

      it 'sets the year' do
        expect(@docs[5].year).to eq('1998')
      end

      it 'sets the volume' do
        expect(@docs[7].volume).to eq('6')
      end

      it 'sets the pages' do
        expect(@docs[8].pages).to eq('113-126')
      end

      it 'does not set the fulltext' do
        expect(@docs[1].fulltext).not_to be
      end
    end
  end

  describe '#author_list' do
    context 'when loading one document' do
      before(:each) do
        @doc = Document.find('doi:10.1111/j.1439-0310.2008.01576.x')
      end

      it 'gets the right number of authors' do
        expect(@doc.author_list.count).to eq(5)
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
    context 'when loading one document' do
      before(:each) do
        @doc = Document.find('doi:10.1111/j.1439-0310.2008.01576.x')
      end

      it 'gets the right number of authors' do
        expect(@doc.formatted_author_list.count).to eq(5)
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
    context 'when loading one document' do
      before(:each) do
        @doc = Document.find('doi:10.1111/j.1439-0310.2008.01576.x')
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
    context 'when loading one document' do
      before(:each) do
        @doc = Document.find('doi:10.1111/j.1439-0310.2008.01576.x')
      end

      it 'does not set any term vectors' do
        expect(@doc.term_vectors).to be_nil
      end
    end

    context 'when loading one document with term vectors' do
      before(:each) do
        @doc = Document.find('doi:10.1111/j.1439-0310.2008.01576.x', term_vectors: true)
      end

      it 'does not load the fulltext' do
        expect(@doc.fulltext).not_to be
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

    context 'when loading one document with offsets' do
      before(:each) do
        @result = Solr::Connection.search(q: 'uid:"doi:10.1111/j.1439-0310.2008.01576.x"',
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
