# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SearchHelper do

  # This is a spec for /lib/core_ext/markdown_handler, but we need access to
  # helper.render, so we have to do this in a helper spec.
  context 'with a Markdown template including ERB' do
    before(:each) do
      @path = Rails.root.join('app', 'views', 'search', 'test_spec.md')
      $spec_markdown_global = 'things'
      File.open(@path, 'w') do |file|
        file.puts('# Testing <%= $spec_markdown_global %> #')
      end
    end

    after(:each) do
      File.delete(@path)
    end

    it 'renders the Markdown as expected' do
      html = helper.render file: @path

      expect(html).to be
      expect(html).to have_selector('h1', text: 'Testing things')
    end
  end

  describe '#num_hits_string' do
    before(:each) do
      @result = double(num_hits: 100)
    end

    context 'when no search has been performed' do
      it 'returns "in database"' do
        expect(helper.num_hits_string(@result)).to eq('100 articles in database')
      end
    end

    context 'when a search has been performed' do
      it 'returns "found"' do
        params[:q] = 'Test search'
        expect(helper.num_hits_string(@result)).to eq('100 articles found')
      end
    end

    context 'when a faceted query has been performed' do
      it 'returns "found"' do
        params[:fq] = ['journal:(Ethology)']
        expect(helper.num_hits_string(@result)).to eq('100 articles found')
      end
    end
  end

  describe '#render_pagination' do
    context 'when we only have one page of results' do
      before(:each) do
        @result = double(num_hits: 1)
        @per_page = 10
        @page = 0
      end

      it 'returns no links' do
        expect(helper.render_pagination(@result)).not_to have_selector('a')
      end
    end

    context 'when we have only one flat range of results' do
      before(:each) do
        @result = double(num_hits: 49)
        @per_page = 10
        @page = 0

        @ret = helper.render_pagination(@result)
      end

      it 'has links for all the pages included' do
        (1..4).each do |n|
          expect(@ret).to have_selector("a[href=\"/search?page=#{n}\"]",
                                        text: (n + 1).to_s)
        end
      end
    end

    context 'when we have more than one page of results' do
      context 'when we are on the first page' do
        before(:each) do
          @result = double(num_hits: 100)
          @per_page = 10
          @page = 0

          @ret = helper.render_pagination(@result)
        end

        it 'returns forward buttons' do
          expect(@ret).to have_selector('a[href="/search?page=1"]', text: '»')
          expect(@ret).to have_selector('a[href="/search?page=9"]', text: '10')
        end

        it 'does not return back buttons' do
          expect(@ret).to have_selector('a[href="#"]', text: '«')
        end
      end

      context 'when we are in the middle' do
        before(:each) do
          @result = double(num_hits: 100)
          @per_page = 10
          @page = params[:page] = 5

          @ret = helper.render_pagination(@result)
        end

        it 'returns back buttons' do
          expect(@ret).to have_selector('a[href="/search?page=4"]', text: '«')
          expect(@ret).to have_selector('a[href="/search"]', text: '1')
        end

        it 'returns forward buttons' do
          expect(@ret).to have_selector('a[href="/search?page=6"]', text: '»')
          expect(@ret).to have_selector('a[href="/search?page=9"]', text: '10')
        end
      end

      context 'when we are on the last page' do
        before(:each) do
          @result = double(num_hits: 100)
          @per_page = 10
          @page = params[:page] = 9

          @ret = helper.render_pagination(@result)
        end

        it 'returns back buttons' do
          expect(@ret).to have_selector('a[href="/search?page=8"]', text: '«')
          expect(@ret).to have_selector('a[href="/search"]', text: '1')
        end

        it 'does not return forward buttons' do
          expect(@ret).to have_selector('a[href="#"]', text: '»')
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
      expect(helper.sort_to_string('authors_sort desc')).to eq('Sort: Authors (descending)')
    end
  end

  describe '#active_filter_list' do
    context 'with nothing active' do
      before(:each) do
        @result = RLetters::Solr::Connection.search(q: '*:*', def_type: 'lucene')
        @facets = FacetsDecorator.decorate(@result.facets)
        @ret = helper.active_filter_list(@result, @facets)
      end

      it 'includes the no-facet text' do
        expect(@ret).to include('No filters active')
      end
    end
  end

  describe '#document_bibliography_entry' do
    context 'when no user is logged in' do
      before(:each) do
        @doc = Document.find(FactoryGirl.generate(:working_uid))

        allow(helper).to receive(:current_user).and_return(nil)
        allow(helper).to receive(:user_signed_in?).and_return(false)
      end

      it 'renders the default template' do
        expect(helper).to receive(:render).with(partial: 'document',
                                                locals: { document: @doc })
        helper.document_bibliography_entry(@doc)
      end
    end

    context 'when the user has no CSL style set' do
      before(:each) do
        @doc = Document.find(FactoryGirl.generate(:working_uid))

        @user = FactoryGirl.create(:user)
        allow(helper).to receive(:current_user).and_return(@user)
        allow(helper).to receive(:user_signed_in?).and_return(true)
      end

      it 'renders the default template' do
        expect(helper).to receive(:render).with(partial: 'document',
                                                locals: { document: @doc })
        helper.document_bibliography_entry(@doc)
      end
    end

    context 'when the user has a CSL style set, for a normal document' do
      before(:each) do
        @doc = Document.find(FactoryGirl.generate(:working_uid))

        @csl_style = Users::CslStyle.find_by!(name: 'American Psychological Association 6th Edition')
        @user = FactoryGirl.create(:user, csl_style_id: @csl_style.id)
        allow(helper).to receive(:current_user).and_return(@user)
        allow(helper).to receive(:user_signed_in?).and_return(true)
      end

      it 'renders a CSL style' do
        expect_any_instance_of(RLetters::Documents::AsCSL).to receive(:entry).with(@csl_style).and_return('')
        helper.document_bibliography_entry(@doc)
      end
    end

    context 'when the user has a CSL style set, for a remote document' do
      before(:each) do
        @doc = Document.find('gutenberg:3172')

        @csl_style = Users::CslStyle.find_by!(name: 'American Psychological Association 6th Edition')
        @user = FactoryGirl.create(:user, csl_style_id: @csl_style.id)
        allow(helper).to receive(:current_user).and_return(@user)
        allow(helper).to receive(:user_signed_in?).and_return(true)
      end

      it 'renders a cloud icon' do
        expect_any_instance_of(RLetters::Documents::AsCSL).to receive(:entry).with(@csl_style).and_return('')
        html = helper.document_bibliography_entry(@doc)

        expect(html).to have_selector('span.fi-upload-cloud')
      end
    end
  end

end
