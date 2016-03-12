require 'rails_helper'

RSpec.describe SearchControllerHelper, type: :helper do
  describe '#document_citation' do
    context 'when no user is logged in' do
      before(:example) do
        @doc = Document.find(generate(:working_uid))

        allow(helper).to receive(:current_user).and_return(nil)
        allow(helper).to receive(:user_signed_in?).and_return(false)
      end

      it 'renders the default template' do
        expect(helper).to receive(:render).with(
          partial: 'document',
          locals: { document: @doc })
        helper.document_citation(@doc)
      end
    end

    context 'when the user has no CSL style set' do
      before(:example) do
        @doc = Document.find(generate(:working_uid))

        @user = create(:user)
        allow(helper).to receive(:current_user).and_return(@user)
        allow(helper).to receive(:user_signed_in?).and_return(true)
      end

      it 'renders the default template' do
        expect(helper).to receive(:render).with(
          partial: 'document',
          locals: { document: @doc })
        helper.document_citation(@doc)
      end
    end

    context 'when the user has a CSL style set, for a normal document' do
      before(:example) do
        @doc = Document.find(generate(:working_uid))

        @csl_style = create(:csl_style)
        @user = create(:user, csl_style_id: @csl_style.id)
        allow(helper).to receive(:current_user).and_return(@user)
        allow(helper).to receive(:user_signed_in?).and_return(true)
      end

      it 'renders a CSL style' do
        expect_any_instance_of(RLetters::Documents::AsCSL).to receive(:entry).with(@csl_style).and_return('')
        helper.document_citation(@doc)
      end
    end

    context 'when the user has a CSL style set, for a remote document' do
      before(:example) do
        @doc = Document.find('gutenberg:3172')

        @csl_style = create(:csl_style)
        @user = create(:user, csl_style_id: @csl_style.id)
        allow(helper).to receive(:current_user).and_return(@user)
        allow(helper).to receive(:user_signed_in?).and_return(true)
      end

      it 'renders a cloud icon' do
        expect_any_instance_of(RLetters::Documents::AsCSL).to receive(:entry).with(@csl_style).and_return('')
        html = helper.document_citation(@doc)

        expect(html).to have_selector('span.fi-upload-cloud')
      end
    end
  end

  describe '#facet_addition_links' do
    context 'with authors facets' do
      before(:example) do
        params = {
          controller: 'search',
          action: 'index'
        }
        allow(helper).to receive(:params).and_return(params)

        @result = RLetters::Solr::Connection.search(q: '*:*', def_type: 'lucene')
        @ret = helper.facet_addition_links(@result.facets, :authors_facet)
      end

      it 'includes a link to add an author facet' do
        url = '/search?' + CGI.escape('fq[]=authors_facet:"Peter J. Hotez"').gsub('%26', '&').gsub('%3D', '=')
        expect(@ret).to have_selector("a[href=\"#{url}\"]")
      end
    end

    context 'with authors facets' do
      before(:example) do
        params = {
          controller: 'search',
          action: 'index'
        }
        allow(helper).to receive(:params).and_return(params)

        @result = RLetters::Solr::Connection.search(q: '*:*', def_type: 'lucene')
        @ret = helper.facet_addition_links(@result.facets, :journal_facet)
      end

      it 'includes a link to add a journal facet' do
        url = '/search?' + CGI.escape('fq[]=journal_facet:"PLoS Neglected Tropical Diseases"').gsub('%26', '&').gsub('%3D', '=')
        expect(@ret).to have_selector("a[href=\"#{url}\"]")
      end
    end

    context 'with year facets' do
      before(:example) do
        params = {
          controller: 'search',
          action: 'index'
        }
        allow(helper).to receive(:params).and_return(params)

        @result = RLetters::Solr::Connection.search(q: '*:*', def_type: 'lucene')
        @ret = helper.facet_addition_links(@result.facets, :year)
      end

      it 'includes a link to add a year facet' do
        url = '/search?' + CGI.escape('fq[]=year:[2000 TO 2009]').gsub('%26', '&').gsub('%3D', '=')
        expect(@ret).to have_selector("a[href=\"#{url}\"]")
      end
    end
  end

  describe '#facet_removal_links' do
    context 'with nothing active' do
      before(:example) do
        params = {
          controller: 'search',
          action: 'index',
          q: '*:*',
          defType: 'lucene'
        }
        allow(helper).to receive(:params).and_return(params)

        @result = RLetters::Solr::Connection.search(params)
        @ret = helper.facet_removal_links(@result.facets)
      end

      it 'does not include anything' do
        expect(@ret).to be_empty
      end
    end

    context 'with a facet active' do
      before(:example) do
        params = {
          controller: 'search',
          action: 'index',
          fq: ['journal_facet:"PLoS Neglected Tropical Diseases"']
        }
        allow(helper).to receive(:params).and_return(params)

        @result = RLetters::Solr::Connection.search(params)
        @ret = helper.facet_removal_links(@result.facets)
      end

      it 'includes the removal link' do
        expect(@ret).to have_css('a[href="/search"]',
                                 text: 'Journal: PLoS Neglected Tropical Diseases')
      end
    end

    context 'with overlapping facet and category active' do
      before(:example) do
        @category = create(:category)
        params = {
          controller: 'search',
          action: 'index',
          categories: [@category.to_param],
          fq: ['journal_facet:"PLoS Neglected Tropical Diseases"']
        }
        allow(helper).to receive(:params).and_return(params)

        @result = RLetters::Solr::Connection.search(params)
        @ret = helper.facet_removal_links(@result.facets)
      end

      it 'includes the facet removal link (with category)' do
        expect(@ret).to have_css("a[href='/search?categories%5B%5D=#{@category.to_param}']",
                                 text: 'Journal: PLoS Neglected Tropical Diseases')
      end
    end
  end

  describe '#category_addition_tree' do
    before(:example) do
      @parent = create(:category, name: 'Parent')
      @child = create(:category, name: 'Child')
      @parent.children << @child
      allow(Documents::Category).to receive(:roots).and_return([@parent])

      params = {
        controller: 'search',
        action: 'index'
      }
      allow(helper).to receive(:params).and_return(params)
    end

    it 'returns a proper tree' do
      tree = helper.category_addition_tree

      expect(tree).to have_selector('li', text: 'Parent')
      expect(tree).to have_selector('li ul li', text: 'Child')
    end
  end

  describe '#category_removal_links' do
    context 'with nothing active' do
      before(:example) do
        params = {
          controller: 'search',
          action: 'index',
          q: '*:*',
          defType: 'lucene'
        }
        allow(helper).to receive(:params).and_return(params)
        @ret = helper.category_removal_links
      end

      it 'does not include anything' do
        expect(@ret).to be_empty
      end
    end

    context 'with a category active' do
      before(:example) do
        @category = create(:category)
        params = {
          controller: 'search',
          action: 'index',
          categories: [@category.to_param]
        }
        allow(helper).to receive(:params).and_return(params)
        @ret = helper.category_removal_links
      end

      it 'includes the removal link' do
        expect(@ret).to have_css('a[href="/search"]',
                                 text: 'Category: Test Category')
      end
    end

    context 'with overlapping facet and category active' do
      before(:example) do
        @category = create(:category)
        params = {
          controller: 'search',
          action: 'index',
          categories: [@category.to_param],
          fq: ['journal_facet:"PLoS Neglected Tropical Diseases"']
        }
        allow(helper).to receive(:params).and_return(params)
        @ret = helper.category_removal_links
      end

      it 'includes the category removal link (with facet)' do
        expect(@ret).to have_css('a[href="/search?fq%5B%5D=journal_facet%3A%22PLoS+Neglected+Tropical+Diseases%22"]',
                                 text: 'Category: Test Category')
      end
    end
  end
end
