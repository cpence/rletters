# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SearchResultDecorator do
  include Capybara::RSpecMatchers

  describe '#num_hits' do
    context 'when no search has been performed' do
      before(:each) do
        @result = described_class.decorate(double(num_hits: 100, params: {}))
      end

      it 'returns "in database"' do
        expect(@result.num_hits).to eq('100 articles in database')
      end
    end

    context 'when a search has been performed' do
      before(:each) do
        @result = described_class.decorate(double(
          num_hits: 100,
          params: { q: 'Test search' }
        ))
      end

      it 'returns "found"' do
        expect(@result.num_hits).to eq('100 articles found')
      end
    end

    context 'when a faceted query has been performed' do
      before(:each) do
        @result = described_class.decorate(double(
          num_hits: 100,
          params: { fq: ['journal:(Ethology)'] }
        ))
      end

      it 'returns "found"' do
        expect(@result.num_hits).to eq('100 articles found')
      end
    end
  end

  describe '#render_pagination' do
    context 'when we only have one page of results' do
      before(:each) do
        @result = described_class.decorate(double(num_hits: 1, params: { 'rows' => 10 }))
      end

      it 'returns no links' do
        expect(@result.pagination).not_to have_selector('a')
      end
    end

    context 'when we have only one flat range of results' do
      before(:each) do
        @result = described_class.decorate(double(num_hits: 49, params: { 'rows' => 10 }))
        @ret = @result.pagination
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
          @result = described_class.decorate(double(num_hits: 100, params: { 'rows' => 10 }))
          @ret = @result.pagination
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
          @result = described_class.decorate(double(num_hits: 100, params: { 'start' => 50, 'rows' => 10 }))
          @ret = @result.pagination
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
          @result = described_class.decorate(double(num_hits: 100, params: { 'start' => 90, 'rows' => 10 }))
          @ret = @result.pagination
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
end
