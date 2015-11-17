require 'rails_helper'

RSpec.describe Document, type: :model do
  it_should_behave_like 'ActiveModel'

  describe '#valid' do
    context 'when no uid is specified' do
      before(:example) do
        @doc = build(:document, uid: nil)
      end

      it 'is not valid' do
        expect(@doc).not_to be_valid
      end
    end

    context 'when a good uid is specified' do
      before(:example) do
        @doc = build(:document)
      end

      it 'is valid' do
        expect(@doc).to be_valid
      end
    end
  end

  describe '.to_global_id' do
    before(:example) do
      @doc = Document.find('doi:10.1371/journal.pntd.0000534')
    end

    it 'works' do
      id = @doc.to_global_id
      expect(id).to be
      expect(id.to_s).to eq('gid://r-letters/Document/doi%3A10.1371%2Fjournal.pntd.0000534')
    end

    it 'allows lookups from GIDs' do
      doc2 = GlobalID::Locator.locate 'gid://r-letters/Document/doi%3A10.1371%2Fjournal.pntd.0000534'
      expect(doc2.uid).to eq(@doc.uid)
      expect(doc2.title).to eq(@doc.title)
    end
  end

  describe '.find' do
    context 'without fulltext' do
      context 'when loading one document' do
        before(:example) do
          @doc = Document.find('doi:10.1371/journal.pntd.0000534')
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
        before(:example) do
          @doc = Document.find('doi:10.1371/journal.pntd.0000534', fulltext: true)
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
      before(:example) do
        stub_connection('http://www.gutenberg.org/cache/epub/3172/pg3172.txt', 'gutenberg')
        @doc = Document.find('gutenberg:3172', fulltext: true, term_vectors: true)
      end

      it 'loads successfully' do
        expect(@doc).to be
      end

      it 'sets the URL' do
        expect(@doc.fulltext_url.to_s).to include('www.gutenberg.org')
      end

      it 'loads the fulltext' do
        expect(@doc.fulltext).to start_with('The Project Gutenberg EBook of')
        expect(WebMock).to have_requested(:get, 'http://www.gutenberg.org/cache/epub/3172/pg3172.txt')
      end

      it 'loads the term vectors' do
        expect(@doc.term_vectors).to be
      end

      it 'fills in term vectors with reasonable quantites' do
        expect(@doc.term_vectors['cooper']['tf']).to be(44)
      end
    end

    context 'with external fulltext (HTTP) with BOM' do
      before(:example) do
        stub_request(:get, /www\.gutenberg\.org/).to_return(
          body: "\xEF\xBB\xBFStart of Response",
          status: 200,
          headers: { 'Content-Length' => 20 })
        @doc = Document.find('gutenberg:3172', fulltext: true, term_vectors: true)
      end

      it 'loads successfully' do
        expect(@doc).to be
      end

      it 'sets the URL' do
        expect(@doc.fulltext_url.to_s).to include('www.gutenberg.org')
      end

      it 'loads the fulltext and strips off the BOM' do
        expect(@doc.fulltext).to start_with('Start of Response')
      end
    end
  end

  describe '.find_by' do
    context 'without fulltext' do
      context 'when loading one document' do
        before(:example) do
          @doc = Document.find_by(uid: 'doi:10.1371/journal.pntd.0000534')
        end

        it 'loads the document successfully' do
          expect(@doc).to be
        end
      end

      context 'when no documents are returned' do
        it 'does not raise an exception' do
          expect { Document.find_by(uid: 'fail') }.not_to raise_error
        end

        it 'returns nil' do
          expect(Document.find_by(uid: 'fail')).to be_nil
        end
      end

      context 'with a field other than uid' do
        before(:example) do
          @doc = Document.find_by(authors: 'Alan Fenwick')
        end

        it 'loads the document successfully' do
          expect(@doc).to be
        end
      end
    end

    context 'with fulltext' do
      context 'when loading one document with fulltext' do
        before(:example) do
          @doc = Document.find_by(uid: 'doi:10.1371/journal.pntd.0000534', fulltext: true)
        end

        it 'loads the document successfully' do
          expect(@doc).to be
        end
      end

      context 'when no documents are returned' do
        it 'does not raise an exception' do
          expect { Document.find_by(uid: 'fail', fulltext: true) }.not_to raise_error
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
      before(:example) do
        @doc = Document.find('doi:10.1371/journal.pntd.0000534')
      end

      it 'gets the right uid' do
        expect(@doc.uid).to eq('doi:10.1371/journal.pntd.0000534')
      end

      it 'does not have any fulltext' do
        expect(@doc.fulltext).to be_nil
      end
    end

    context 'when loading one document with fulltext' do
      before(:example) do
        @doc = Document.find('doi:10.1371/journal.pntd.0000534', fulltext: true)
      end

      it 'gets the right uid' do
        expect(@doc.uid).to eq('doi:10.1371/journal.pntd.0000534')
      end

      it 'loads the fulltext' do
        expect(@doc.fulltext).to be
      end

      it 'does not load term vectors' do
        expect(@doc.term_vectors).not_to be
      end
    end

    context 'when loading a set of documents' do
      before(:example) do
        @result = RLetters::Solr::Connection.search(q: '*:*', def_type: 'lucene')
        @docs = @result.documents
      end

      it 'sets the uid' do
        expect(@docs[0].uid).to eq('doi:10.1371/journal.pntd.0000503')
      end

      it 'sets the doi' do
        expect(@docs[3].doi).to eq('10.1371/journal.pntd.0000506')
      end

      it 'sets the license' do
        expect(@docs[0].license).to eq('Creative Commons Attribution (CC BY)')
      end

      it 'sets the license URL' do
        expect(@docs[2].license_url).to eq('http://creativecommons.org/licenses/by/3.0/')
      end

      it 'sets the authors' do
        authors = [
          'Ana Thereza Chaves', 'Andrea Teixeira-Carvalho',
          'Fernanda Fortes de Araújo', 'Guilherme Grossi Lopes Cançado',
          'Jacqueline Araújo Fiuza', 'Juliana Assis Silva Gomes',
          'Manoel Otávio das Costa Rocha', 'Olindo de Assis Martins-Filho',
          'Rafaelle Christine Gomes Fares', 'Ricardo Toshio Fujiwara',
          'Rodrigo Correa-Oliveira'
        ]
        expect(@docs[9].authors.map(&:full)).to match_array(authors)
      end

      it 'sets the title' do
        expect(@docs[2].title).to eq('A Schistosome cAMP-Dependent Protein Kinase Catalytic Subunit Is Essential for Parasite Viability')
      end

      it 'sets the journal' do
        expect(@docs[0].journal).to eq('PLoS Neglected Tropical Diseases')
      end

      it 'sets the year' do
        expect(@docs[5].year).to eq('2009')
      end

      it 'sets the volume' do
        expect(@docs[7].volume).to eq('3')
      end

      it 'sets the pages' do
        expect(@docs[8].pages).to eq('e511')
      end

      it 'does not set the fulltext' do
        expect(@docs[1].fulltext).not_to be
      end
    end

    context 'when loading a document with blank attributes' do
      before do
        @doc = build(:full_document, volume: '', number: '   ')
      end

      it 'nils out empty strings' do
        expect(@doc.volume).to be_nil
      end

      it 'nils out blank strings' do
        expect(@doc.number).to be_nil
      end
    end
  end

  describe '#start_page and #end_page' do
    context 'when loading one document' do
      before(:example) do
        @doc = build(:document, pages: '1227-1238')
      end

      it 'parses start_page correctly' do
        expect(@doc.start_page).to eq('1227')
      end

      it 'parses end_page correctly' do
        expect(@doc.end_page).to eq('1238')
      end
    end

    context 'when loading a document with funny page ranges' do
      before(:example) do
        @doc = build(:document, pages: '1483-92')
      end

      it 'parses start_page correctly' do
        expect(@doc.start_page).to eq('1483')
      end

      it 'parses end_page correctly' do
        expect(@doc.end_page).to eq('1492')
      end
    end

    context 'when loading a document without a range' do
      before(:example) do
        @doc = build(:document, pages: 'e1234')
      end

      it 'parses start_page correctly' do
        expect(@doc.start_page).to eq('e1234')
      end

      it 'parses end_page correctly' do
        expect(@doc.end_page).not_to be
      end
    end
  end

  describe '#term_vectors' do
    context 'when loading one document' do
      before(:example) do
        @doc = Document.find('doi:10.1371/journal.pntd.0000534')
      end

      it 'does not set any term vectors' do
        expect(@doc.term_vectors).to be_nil
      end
    end

    context 'when loading one document with term vectors' do
      before(:example) do
        @doc = Document.find('doi:10.1371/journal.pntd.0000534', term_vectors: true)
      end

      it 'does not load the fulltext' do
        expect(@doc.fulltext).not_to be
      end

      it 'sets the term vectors' do
        expect(@doc.term_vectors).to be
      end

      it 'sets tf' do
        expect(@doc.term_vectors['decrease'][:tf]).to eq(2)
      end

      it 'sets positions' do
        expect(@doc.term_vectors['hyperendemic'][:positions][0]).to eq(21)
      end

      it 'sets df' do
        expect(@doc.term_vectors['population'][:df]).to eq(389)
      end

      it 'does not set anything for terms that do not appear' do
        expect(@doc.term_vectors['zuzax']).not_to be
      end
    end
  end
end
