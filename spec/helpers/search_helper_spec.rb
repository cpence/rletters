# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SearchHelper do

  describe '#num_results_string' do
    before(:each) do
      @result = mock(Solr::SearchResult, num_results: 100)
    end

    context 'when no search has been performed' do
      it 'returns "in database"' do
        expect(helper.num_results_string(@result)).to eq('100 articles in database')
      end
    end

    context 'when a search has been performed' do
      it 'returns "found"' do
        params[:q] = 'Test search'
        expect(helper.num_results_string(@result)).to eq('100 articles found')
      end
    end

    context 'when a faceted query has been performed' do
      it 'returns "found"' do
        params[:fq] = ['journal:(Ethology)']
        expect(helper.num_results_string(@result)).to eq('100 articles found')
      end
    end
  end

  describe '#render_pagination' do
    context 'when we only have one page of results' do
      before(:each) do
        @result = mock(Solr::SearchResult, num_results: 1)
        @per_page = 10
        @page = 0
      end

      it 'returns no links' do
        expect(helper.render_pagination(@result)).not_to have_tag('a')
      end
    end

    context 'when we have more than one page of results' do
      context 'when we are on the first page' do
        before(:each) do
          @result = mock(Solr::SearchResult, num_results: 100)
          @per_page = 10
          @page = 0

          @ret = helper.render_pagination(@result)
        end

        it 'returns forward buttons' do
          expect(@ret).to have_tag('a[href="/search/?page=1"][data-icon=arrow-r][data-iconpos=right]', text: 'Next')
          expect(@ret).to have_tag('a[href="/search/?page=9"][data-icon=forward][data-iconpos=right]', text: 'Last')
        end

        it 'does not return back buttons' do
          expect(@ret).not_to have_tag('a[data-icon=arrow-l]')
          expect(@ret).not_to have_tag('a[data-icon=back]')
        end
      end

      context 'when we are in the middle' do
        before(:each) do
          @result = mock(Solr::SearchResult, num_results: 100)
          @per_page = 10
          @page = params[:page] = 5

          @ret = helper.render_pagination(@result)
        end

        it 'returns back buttons' do
          expect(@ret).to have_tag('a[href="/search/?page=4"][data-icon=arrow-l]', text: 'Previous')
          expect(@ret).to have_tag('a[href="/search/"][data-icon=back]', text: 'First')
        end

        it 'returns forward buttons' do
          expect(@ret).to have_tag('a[href="/search/?page=6"][data-icon=arrow-r][data-iconpos=right]', text: 'Next')
          expect(@ret).to have_tag('a[href="/search/?page=9"][data-icon=forward][data-iconpos=right]', text: 'Last')
        end
      end

      context 'when we are on the last page' do
        before(:each) do
          @result = mock(Solr::SearchResult, num_results: 100)
          @per_page = 10
          @page = params[:page] = 9

          @ret = helper.render_pagination(@result)
        end

        it 'returns back buttons' do
          expect(@ret).to have_tag('a[href="/search/?page=8"][data-icon=arrow-l]', text: 'Previous')
          expect(@ret).to have_tag('a[href="/search/"][data-icon=back]', text: 'First')
        end

        it 'does not return forward buttons' do
          expect(@ret).not_to have_tag('a[data-icon=arrow-r]')
          expect(@ret).not_to have_tag('a[data-icon=forward]')
        end
      end
    end
  end

  describe '#sort_to_string' do
    it 'returns the right thing for relevance' do
      expect(helper.sort_to_string('score desc')).to eq('Sort: Relevance')
    end

    it 'returns the right thing for other sort fields' do
      expect(helper.sort_to_string('title_sort asc')).to eq('Sort: Title (ascending)')
      expect(helper.sort_to_string('journal_sort desc')).to eq('Sort: Journal (descending)')
      expect(helper.sort_to_string('year_sort asc')).to eq('Sort: Year (ascending)')
    end
  end

  describe '#list_links_for_facet', vcr: { cassette_name: 'solr_default' } do
    before(:each) do
      @result = Solr::Connection.find({ q: '*:*', qt: 'precise' })
    end

    context 'with no active facets' do
      before(:each) do
        @ret = helper.list_links_for_facet(@result, :authors_facet, 'Authors', [])
      end

      it 'includes a header' do
        expect(@ret).to have_tag('li[data-role=list-divider]', text: 'Authors')
      end

      it 'includes a link to add a facet' do
        url = '/search/?' + CGI.escape('fq[]=authors_facet:"J. C. Crabbe"').gsub('%26', '&').gsub('%3D', '=')
        expect(@ret).to have_tag("a[href=\"#{url}\"]", text: 'J. C. Crabbe')
      end
    end

    context 'with an active facet' do
      before(:each) do
        @ret = helper.list_links_for_facet(@result, :authors_facet, 'Authors', [@result.facets.for_query('authors_facet:"J. C. Crabbe"')])
      end

      it 'does not include the active facet in the list' do
        expect(@ret).not_to have_tag('li', text: 'J. C. Crabbe9')
      end

      it 'does include the sixth facet in the list' do
        url = '/search/?' + CGI.escape('fq[]=authors_facet:"J. C. Crabbe"&fq[]=authors_facet:"J. N. Crawley"').gsub('%26', '&').gsub('%3D', '=')
        expect(@ret).to have_tag("a[href=\"#{url}\"]", text: 'J. N. Crawley')
      end
    end
  end

  describe '#facet_link_list' do
    context 'when no facets present' do
      before(:each) do
        @result = mock(Solr::SearchResult, facets: nil)
      end

      it 'returns an empty string' do
        expect(helper.facet_link_list(@result)).to eq('')
      end
    end

    context 'with no active facets', vcr: { cassette_name: 'solr_default' } do
      before(:each) do
        @result = Solr::Connection.find({ q: '*:*', qt: 'precise' })
        @ret = helper.facet_link_list(@result)
      end

      it 'includes the headers' do
        expect(@ret).to have_tag('li[data-role=list-divider]', text: 'Authors')
        expect(@ret).to have_tag('li[data-role=list-divider]', text: 'Journal')
        expect(@ret).to have_tag('li[data-role=list-divider]', text: 'Publication Date')
      end

      it 'includes a link to add an author facet' do
        url = '/search/?' + CGI.escape('fq[]=authors_facet:"J. C. Crabbe"').gsub('%26', '&').gsub('%3D', '=')
        expect(@ret).to have_tag("a[href=\"#{url}\"]", text: 'J. C. Crabbe')
      end

      it 'includes a link to add a journal facet' do
        url = '/search/?' + CGI.escape('fq[]=journal_facet:"Ethology"').gsub('%26', '&').gsub('%3D', '=')
        expect(@ret).to have_tag("a[href=\"#{url}\"]", text: 'Ethology')
      end

      it 'includes a link to add a year facet' do
        url = '/search/?' + CGI.escape('fq[]=year:[2000 TO 2009]').gsub('%26', '&').gsub('%3D', '=')
        expect(@ret).to have_tag("a[href=\"#{url}\"]", text: '2000–2009')
      end
    end

    context 'with active facets',
            vcr: { cassette_name: 'search_helper_facets' } do
      before(:each) do
        @result = Solr::Connection.find({ q: '*:*', qt: 'precise',
                                          fq: ['authors_facet:"Elisa Lobato"', 'year:[2010 TO *]'] })

        params[:fq] = ['authors_facet:"Elisa Lobato"', 'year:[2010 TO *]']
        @ret = helper.facet_link_list(@result)
      end

      it 'includes a link to remove all facets' do
        expect(@ret).to have_tag('a[href="/search/"]', text: 'Remove All')
      end

      it 'includes a link to remove an individual facet' do
        url = '/search/?' + CGI.escape('fq[]=year:[2010 TO *]').gsub('%26', '&').gsub('%3D', '=')
        expect(@ret).to have_tag("a[href=\"#{url}\"]", text: 'Authors: Elisa Lobato')
      end
    end
  end

  describe '#document_bibliography_entry',
           vcr: { cassette_name: 'solr_single' } do
    before(:each) do
      @doc = Document.find(FactoryGirl.generate(:working_shasum))
    end

    context 'when no user is logged in' do
      before(:each) do
        allow(helper).to receive(:current_user).and_return(nil)
        allow(helper).to receive(:user_signed_in?).and_return(false)
      end

      it 'renders the default template' do
        expect(helper).to receive(:render).with({ partial: 'document',
                                                  locals: { document: @doc } })
        helper.document_bibliography_entry(@doc)
      end
    end

    context 'when the user has no CSL style set' do
      before(:each) do
        @user = FactoryGirl.create(:user)
        allow(helper).to receive(:current_user).and_return(@user)
        allow(helper).to receive(:user_signed_in?).and_return(true)
      end

      it 'renders the default template' do
        expect(helper).to receive(:render).with({ partial: 'document',
                                                  locals: { document: @doc } })
        helper.document_bibliography_entry(@doc)
      end
    end

    context 'when the user has a CSL style set' do
      before(:each) do
        @csl_style = CslStyle.find_by!(name: 'American Psychological Association 6th Edition')
        @user = FactoryGirl.create(:user, csl_style_id: @csl_style.id)
        allow(helper).to receive(:current_user).and_return(@user)
        allow(helper).to receive(:user_signed_in?).and_return(true)
      end

      it 'renders a CSL style' do
        expect(@doc).to receive(:to_csl_entry).with(@csl_style)
        helper.document_bibliography_entry(@doc)
      end
    end
  end

end
