require 'spec_helper'

RSpec.describe Admin::AdminMarkdownPagesController, type: :controller do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:example) do
    @page = create(:markdown_page)
    @administrator = create(:administrator)
    sign_in :administrator, @administrator
  end

  describe '#index' do
    before(:example) do
      get :index
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'includes the Markdown page in the list' do
      expect(response.body).to satisfy do |s|
        s.include?(@page.name) || s.include?('The Friendly Name')
      end
    end
  end

  describe '#show' do
    before(:example) do
      get :show, id: @page.to_param
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'renders the page Markdown to HTML' do
      expect(response.body).to include('</h1>')
    end
  end

  describe '#edit' do
    before(:example) do
      get :edit, id: @page.to_param
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'has a textarea field for the content' do
      expect(response.body).to have_selector('textarea[name="admin_markdown_page[content]"]')
    end
  end
end
