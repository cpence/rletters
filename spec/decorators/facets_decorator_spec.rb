require 'spec_helper'

RSpec.describe FacetsDecorator, type: :decorator do
  include Capybara::RSpecMatchers

  describe '#removal_links' do
    context 'with no active facets' do
      before(:example) do
        @result = RLetters::Solr::Connection.search(q: '*:*', def_type: 'lucene')
        @ret = described_class.decorate(@result.facets).removal_links
      end

      it 'is blank' do
        expect(@ret).to be_empty
      end
    end

    context 'with active facets' do
      before(:example) do
        @result = RLetters::Solr::Connection.search(
          q: '*:*',
          def_type: 'lucene',
          fq: ['authors_facet:"Alan Fenwick"', 'year:[2000 TO 2009]'])

        Draper::ViewContext.current.params[:fq] = ['authors_facet:"Alan Fenwick"', 'year:[2000 TO 2009]']
        @ret = described_class.decorate(@result.facets).removal_links
      end

      it 'includes a link to remove an individual facet' do
        url = '/search?' + CGI.escape('fq[]=year:[2000 TO 2009]').gsub('%26', '&').gsub('%3D', '=')
        expect(@ret).to have_selector("a[href=\"#{url}\"]", text: 'Authors: Alan Fenwick')
      end
    end
  end

  describe '#addition_links' do
    context 'with some facets' do
      before(:example) do
        @result = RLetters::Solr::Connection.search(q: '*:*', def_type: 'lucene')
        @ret = described_class.decorate(@result.facets).addition_links
      end

      it 'includes the headers' do
        expect(@ret).to include('>Authors<')
        expect(@ret).to include('>Journal<')
        expect(@ret).to include('>Publication Date<')
      end

      it 'includes a link to add an author facet' do
        url = '/search?' + CGI.escape('fq[]=authors_facet:"Peter J. Hotez"').gsub('%26', '&').gsub('%3D', '=')
        expect(@ret).to have_selector("a[href=\"#{url}\"]")
      end

      it 'includes a link to add a journal facet' do
        url = '/search?' + CGI.escape('fq[]=journal_facet:"PLoS Neglected Tropical Diseases"').gsub('%26', '&').gsub('%3D', '=')
        expect(@ret).to have_selector("a[href=\"#{url}\"]")
      end

      it 'includes a link to add a year facet' do
        url = '/search?' + CGI.escape('fq[]=year:[2000 TO 2009]').gsub('%26', '&').gsub('%3D', '=')
        expect(@ret).to have_selector("a[href=\"#{url}\"]")
      end
    end
  end
end
