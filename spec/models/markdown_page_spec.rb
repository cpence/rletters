# -*- encoding : utf-8 -*-
require 'spec_helper'

describe MarkdownPage do

  describe '#valid?' do
    context 'when no name spcified' do
      before(:each) do
        @page = FactoryGirl.build(:markdown_page, name: nil)
      end

      it "isn't valid" do
        @page.should_not be_valid
      end
    end

    context 'when all parameters are valid' do
      before(:each) do
        @page = FactoryGirl.build(:markdown_page)
      end

      it 'is valid' do
        @page.should be_valid
      end
    end
  end

  describe '#friendly_name' do
    before(:each) do
      @page = FactoryGirl.create(:markdown_page)
    end

    it 'returns the plain name with no translation, friendly name with translation' do
      # There's no way to *delete* a translation from the I18n backend, so
      # we have to do this in one test to make sure they're in order
      @page.friendly_name.should eq(@page.name)

      I18n.backend.store_translations :en, markdown_pages: { @page.name.to_sym => 'The Friendly Name' }
      @page.friendly_name.should eq('The Friendly Name')
    end
  end

  describe '.render' do
    before(:each) do
      @page = FactoryGirl.create(:markdown_page)
    end

    context 'when a non-existent page is specified' do
      it 'returns an empty string' do
        MarkdownPage.render('not_a_page_id').should eq('')
      end
    end

    context 'when an extant page is specified' do
      it 'renders the page' do
        MarkdownPage.render(@page.name).should include('<h1 id="header">Header</h1>')
      end
    end
  end

end
