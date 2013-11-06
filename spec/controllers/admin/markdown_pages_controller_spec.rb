# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin::MarkdownPagesController do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:each) do
    @admin_user = FactoryGirl.create(:admin_user)
    sign_in :admin_user, @admin_user
  end

  describe '#index' do
    before(:each) do
      get :index
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'includes one of the markdown pages' do
      expect(response.body).to include('Landing Page')
    end
  end

  describe '#show' do
    before(:each) do
      @page = MarkdownPage.find_by!(name: 'landing')
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
    before(:each) do
      @page = MarkdownPage.find_by!(name: 'landing')
      get :edit, id: @page.to_param
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'has a textarea field for the content' do
      expect(response.body).to have_selector('textarea[name="markdown_page[content]"]')
    end
  end

end
