# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SearchController do

  describe '#index' do
    context 'with empty search results' do
      before(:each) do
        get :index, { q: 'fail' }
      end

      it 'loads successfully' do
        expect(response).to be_success
      end
    end

    context 'with precise search results' do
      before(:each) do
        get :index
      end

      it 'assigns the search result' do
        expect(assigns(:result)).to be
      end

      it 'assigns the documents variable' do
        expect(assigns(:documents)).to be
      end

      it 'assigns the right number of documents' do
        expect(assigns(:documents).count).to eq(10)
      end

      it 'assigns solr_q' do
        expect(assigns(:solr_q)).to eq('*:*')
      end

      it 'assigns solr_defType' do
        expect(assigns(:solr_defType)).to eq('lucene')
      end

      it 'does not assign solr_fq' do
        expect(assigns(:solr_fq)).to be_nil
      end

      it 'sorts by year, descending' do
        expect(assigns(:sort)).to eq('year_sort desc')
      end
    end

    context 'with faceted search results' do
      before(:each) do
        expect(Solr::Connection).to receive(:search).and_return(double(Solr::SearchResult, documents: []))
        get :index, { fq: ['journal_facet:"Journal of Nothing"'] }
      end

      it 'assigns solr_fq' do
        expect(assigns(:solr_fq)).to be
      end

      it 'sorts by year, descending' do
        expect(assigns(:sort)).to eq('year_sort desc')
      end
    end

    context 'with a dismax search' do
      before(:each) do
        expect(Solr::Connection).to receive(:search).and_return(double(Solr::SearchResult, documents: []))
        get :index, { q: 'testing' }
      end

      it 'assigns solr_q' do
        expect(assigns(:solr_q)).to eq('testing')
      end

      it 'assigns solr_defType' do
        expect(assigns(:solr_defType)).to eq('dismax')
      end

      it 'does not assign solr_fq' do
        expect(assigns(:solr_fq)).to be_nil
      end

      it 'sorts by score, descending' do
        expect(assigns(:sort)).to eq('score desc')
      end
    end

    context 'with offset and limit parameters' do
      it 'successfully parses those parameters' do
        default_sq = { q: '*:*', defType: 'lucene', sort: 'year_sort desc', start: 20, rows: 20 }
        expect(Solr::Connection).to receive(:search).with(default_sq).and_return(double(Solr::SearchResult, documents: []))

        get :index, { page: '1', per_page: '20' }

        expect(assigns(:documents)).to be_empty
      end

      it 'does not throw an exception on non-integral page values' do
        default_sq = { q: '*:*', defType: 'lucene', sort: 'year_sort desc', start: 0, rows: 20 }
        expect(Solr::Connection).to receive(:search).with(default_sq).and_return(double(Solr::SearchResult, documents: []))

        expect {
          get :index, { page: 'zzyzzy', per_page: '20' }
        }.to_not raise_error
      end

      it 'does not throw an exception on non-integral per_page values' do
        default_sq = { q: '*:*', defType: 'lucene', sort: 'year_sort desc', start: 10, rows: 10 }
        expect(Solr::Connection).to receive(:search).with(default_sq).and_return(double(Solr::SearchResult, documents: []))

        expect {
          get :index, { page: '1', per_page: 'zzyzzy' }
        }.to_not raise_error
      end

      it 'does not let the user specify zero items per page' do
        default_sq = { q: '*:*', defType: 'lucene', sort: 'year_sort desc', start: 10, rows: 10 }
        expect(Solr::Connection).to receive(:search).with(default_sq).and_return(double(Solr::SearchResult, documents: []))

        get :index, { page: '1', per_page: '0' }
      end
    end
  end

  describe '#export' do
    context 'when displaying as HTML' do
      it 'will not load' do
        get :export, { uid: FactoryGirl.generate(:working_uid) }
        expect(controller.response.response_code).to eq(406)
      end
    end

    context 'when exporting in other formats' do
      it 'exports in MARC format' do
        get :export, { uid: FactoryGirl.generate(:working_uid),
                       format: 'marc' }
        expect(response).to be_valid_download('application/marc')
      end

      it 'exports in MARC-JSON format' do
        get :export, { uid: FactoryGirl.generate(:working_uid),
                       format: 'json' }
        expect(response).to be_valid_download('application/json')
      end

      it 'exports in MARC-XML format' do
        get :export, { uid: FactoryGirl.generate(:working_uid),
                       format: 'marcxml' }
        expect(response).to be_valid_download('application/marcxml+xml')
      end

      it 'exports in BibTeX format' do
        get :export, { uid: FactoryGirl.generate(:working_uid),
                       format: 'bibtex' }
        expect(response).to be_valid_download('application/x-bibtex')
      end

      it 'exports in EndNote format' do
        get :export, { uid:  FactoryGirl.generate(:working_uid),
                       format: 'endnote' }
        expect(response).to be_valid_download('application/x-endnote-refer')
      end

      it 'exports in RIS format' do
        get :export, { uid:  FactoryGirl.generate(:working_uid),
                       format: 'ris' }
        expect(response).to be_valid_download('application/x-research-info-systems')
      end

      it 'exports in MODS format' do
        get :export, { uid:  FactoryGirl.generate(:working_uid),
                       format: 'mods' }
        expect(response).to be_valid_download('application/mods+xml')
      end

      it 'exports in RDF/XML format' do
        get :export, { uid:  FactoryGirl.generate(:working_uid),
                       format: 'rdf' }
        expect(response).to be_valid_download('application/rdf+xml')
      end

      it 'exports in RDF/N3 format' do
        get :export, { uid: FactoryGirl.generate(:working_uid),
                       format: 'n3' }
        expect(response).to be_valid_download('text/rdf+n3')
      end

      it 'fails to export an invalid format' do
        get :export, { uid: FactoryGirl.generate(:working_uid),
                       format: 'csv' }
        expect(controller.response.response_code).to eq(406)
      end
    end
  end

  describe '#add' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user

      @document = Document.find(FactoryGirl.generate(:working_uid))
      @dataset = FactoryGirl.create(:dataset, user: @user, name: 'Enabled')
      @disabled = FactoryGirl.create(:dataset, user: @user, name: 'Disabled', disabled: true)

      get :add, { uid: @document.uid }
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'sets the document' do
      expect(assigns(:document).uid).to eq(@document.uid)
    end

    it 'sets the datasets, ignoring disabled' do
      expect(assigns(:datasets)).to eq([@dataset])
    end
  end

  describe '#to_mendeley' do
    context 'when request succeeds' do
      before(:all) do
        Setting.mendeley_key = '5ba3606d28aa1be94e9c58502b90a49c04dc17289'
      end

      after(:all) do
        Setting.mendeley_key = ''
      end

      it 'redirects to Mendeley' do
        stub_connection(/api.mendeley.com/, 'mendeley')
        get :to_mendeley, { uid: 'doi:10.1111/j.1439-0310.2008.01576.x' }
        expect(response).to redirect_to('http://www.mendeley.com/catalog/choose-good-scientific-problem-1/')
      end
    end

    context 'when request times out' do
      before(:all) do
        Setting.mendeley_key = '5ba3606d28aa1be94e9c58502b90a49c04dc17289'
      end

      after(:all) do
        Setting.mendeley_key = ''
      end

      before(:each) do
        stub_request(:any, /api\.mendeley\.com\/.*/).to_timeout
      end

      it 'raises an exception' do
        expect {
          get :to_mendeley, { uid: 'doi:10.1111/j.1439-0310.2008.01576.x' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#to_citeulike' do
    context 'when request succeeds' do
      it 'redirects to citeulike' do
        stub_connection(/www.citeulike.org/, 'citeulike')
        get :to_citeulike, { uid: 'doi:10.1111/j.1439-0310.2008.01576.x' }
        expect(response).to redirect_to('http://www.citeulike.org/article/3509563')
      end
    end

    context 'when request times out' do
      before(:each) do
        stub_request(:any, %r{www\.citeulike\.org/json/.*}).to_timeout
      end

      it 'raises an exception' do
        expect {
          get :to_citeulike, { uid: 'doi:10.1111/j.1439-0310.2008.01576.x' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#advanced' do
    it 'loads successfully' do
      get :advanced
      expect(response).to be_success
    end
  end

end
