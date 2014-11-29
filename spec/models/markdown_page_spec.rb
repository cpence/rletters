# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe Admin::MarkdownPage, type: :model do

  describe '#valid?' do
    context 'when no name spcified' do
      before(:example) do
        @page = build_stubbed(:markdown_page, name: nil)
      end

      it 'is not valid' do
        expect(@page).not_to be_valid
      end
    end

    context 'when all parameters are valid' do
      before(:example) do
        @page = build_stubbed(:markdown_page)
      end

      it 'is valid' do
        expect(@page).to be_valid
      end
    end
  end

  describe '#friendly_name' do
    before(:example) do
      @page = create(:markdown_page)
    end

    it 'returns the plain name with no translation, friendly name with translation' do
      # There's no way to *delete* a translation from the I18n backend, so
      # we have to do this in one test to make sure they're in order
      expect(@page.friendly_name).to eq(@page.name)

      I18n.backend.store_translations :en, markdown_pages:
        { @page.name.to_sym => 'The Friendly Name' }
      expect(@page.friendly_name).to eq('The Friendly Name')
    end
  end

  describe '.render' do
    before(:example) do
      @page = create(:markdown_page)
    end

    context 'when a non-existent page is specified' do
      it 'returns an empty string' do
        expect(Admin::MarkdownPage.render('not_a_page_id')).to eq('')
      end
    end

    context 'when an extant page is specified' do
      it 'renders the page' do
        expect(Admin::MarkdownPage.render(@page.name)).to include('<h1 id="header">Header</h1>')
      end
    end
  end

end
