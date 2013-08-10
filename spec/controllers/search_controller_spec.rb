# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SearchController do

  describe '#index' do
    context 'with empty search results',
            vcr: { cassette_name: 'search_controller_fail' } do
      before(:each) do
        get :index, { q: 'fail' }
      end

      it 'loads successfully' do
        expect(response).to be_success
      end
    end

    context 'with precise search results',
            vcr: { cassette_name: 'search_controller_default' } do
      before(:each) do
        get :index
      end

      it 'assigns the documents variable' do
        expect(assigns(:documents)).to be
      end

      it 'assigns the right number of documents' do
        expect(assigns(:documents)).to have(10).items
      end

      it 'assigns solr_q' do
        expect(assigns(:solr_q)).to eq('*:*')
      end

      it 'assigns solr_qt' do
        expect(assigns(:solr_qt)).to eq('precise')
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
        expect(Document).to receive(:find_all_by_solr_query).and_return([])
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
        expect(Document).to receive(:find_all_by_solr_query).and_return([])
        get :index, { q: 'testing' }
      end

      it 'assigns solr_q' do
        expect(assigns(:solr_q)).to eq('testing')
      end

      it 'assigns solr_qt' do
        expect(assigns(:solr_qt)).to eq('standard')
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
        default_sq = { q: '*:*', qt: 'precise' }
        options = { sort: 'year_sort desc', offset: 20, limit: 20 }
        expect(Document).to receive(:find_all_by_solr_query).with(default_sq, options).and_return([])

        get :index, { page: '1', per_page: '20' }

        expect(assigns(:documents)).to have(0).items
      end

      it 'does not throw an exception on non-integral page values' do
        default_sq = { q: '*:*', qt: 'precise' }
        options = { sort: 'year_sort desc', offset: 0, limit: 20 }
        expect(Document).to receive(:find_all_by_solr_query).with(default_sq, options).and_return([])

        expect {
          get :index, { page: 'zzyzzy', per_page: '20' }
        }.to_not raise_error
      end

      it 'does not throw an exception on non-integral per_page values' do
        default_sq = { q: '*:*', qt: 'precise' }
        options = { sort: 'year_sort desc', offset: 10, limit: 10 }
        expect(Document).to receive(:find_all_by_solr_query).with(default_sq, options).and_return([])

        expect {
          get :index, { page: '1', per_page: 'zzyzzy' }
        }.to_not raise_error
      end

      it 'does not let the user specify zero items per page' do
        default_sq = { q: '*:*', qt: 'precise' }
        options = { sort: 'year_sort desc', offset: 10, limit: 10 }
        expect(Document).to receive(:find_all_by_solr_query).with(default_sq, options).and_return([])

        get :index, { page: '1', per_page: '0' }
      end
    end
  end

  describe '#show', vcr: { cassette_name: 'solr_single' } do
    context 'when displaying as HTML' do
      it 'loads successfully' do
        get :show, { id: FactoryGirl.generate(:working_shasum) }
        expect(response).to be_success
      end

      it 'assigns document' do
        get :show, { id: FactoryGirl.generate(:working_shasum) }
        expect(assigns(:document)).to be
      end
    end

    context 'when exporting in other formats' do
      it 'exports in MARC format' do
        get :show, { id: FactoryGirl.generate(:working_shasum),
                     format: 'marc' }
        expect(response).to be_valid_download('application/marc')
      end

      it 'exports in MARC-JSON format' do
        get :show, { id: FactoryGirl.generate(:working_shasum),
                     format: 'json' }
        expect(response).to be_valid_download('application/json')
      end

      it 'exports in MARC-XML format' do
        get :show, { id: FactoryGirl.generate(:working_shasum),
                     format: 'marcxml' }
        expect(response).to be_valid_download('application/marcxml+xml')
      end

      it 'exports in BibTeX format' do
        get :show, { id: FactoryGirl.generate(:working_shasum),
                     format: 'bibtex' }
        expect(response).to be_valid_download('application/x-bibtex')
      end

      it 'exports in EndNote format' do
        get :show, { id:  FactoryGirl.generate(:working_shasum),
                     format: 'endnote' }
        expect(response).to be_valid_download('application/x-endnote-refer')
      end

      it 'exports in RIS format' do
        get :show, { id:  FactoryGirl.generate(:working_shasum),
                     format: 'ris' }
        expect(response).to be_valid_download('application/x-research-info-systems')
      end

      it 'exports in MODS format' do
        get :show, { id:  FactoryGirl.generate(:working_shasum),
                     format: 'mods' }
        expect(response).to be_valid_download('application/mods+xml')
      end

      it 'exports in RDF/XML format' do
        get :show, { id:  FactoryGirl.generate(:working_shasum),
                     format: 'rdf' }
        expect(response).to be_valid_download('application/rdf+xml')
      end

      it 'exports in RDF/N3 format' do
        get :show, { id: FactoryGirl.generate(:working_shasum),
                     format: 'n3' }
        expect(response).to be_valid_download('text/rdf+n3')
      end

      it 'fails to export an invalid format' do
        get :show, { id: FactoryGirl.generate(:working_shasum),
                     format: 'csv' }
        expect(controller.response.response_code).to eq(406)
      end
    end
  end

  describe '#add', vcr: { cassette_name: 'solr_single' } do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it 'loads successfully' do
      get :add, { id: FactoryGirl.generate(:working_shasum) }
      expect(response).to be_success
    end
  end

  describe '#to_mendeley', vcr: { cassette_name: 'search_mendeley' } do
    context 'when request succeeds' do
      before(:all) do
        Setting.mendeley_key = '5ba3606d28aa1be94e9c58502b90a49c04dc17289'
      end

      after(:all) do
        Setting.mendeley_key = ''
      end

      it 'redirects to Mendeley' do
        get :to_mendeley, { id: '00972c5123877961056b21aea4177d0dc69c7318' }
        expect(response).to redirect_to('http://www.mendeley.com/research/reliable-methods-estimating-repertoire-size-1/')
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
          get :to_mendeley, { id: '00972c5123877961056b21aea4177d0dc69c7318' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#to_citeulike', vcr: { cassette_name: 'search_citeulike' } do
    context 'when request succeeds' do
      it 'redirects to citeulike' do
        get :to_citeulike, { id: '00972c5123877961056b21aea4177d0dc69c7318' }
        expect(response).to redirect_to('http://www.citeulike.org/article/3509563')
      end
    end

    context 'when request times out' do
      before(:each) do
        stub_request(:any, %r{www\.citeulike\.org/json/.*}).to_timeout
      end

      it 'raises an exception' do
        expect {
          get :to_citeulike, { id: '00972c5123877961056b21aea4177d0dc69c7318' }
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

  describe '#sort_methods' do
    it 'loads successfully' do
      get :sort_methods
      expect(response).to be_success
    end
  end

end
