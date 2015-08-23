require 'rails_helper'

RSpec.describe Admin::DocumentsStopListsController, type: :controller do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:example) do
    @list = create(:stop_list)
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

    it 'includes one of the stop lists' do
      expect(response.body).to include(@list.language)
    end
  end

  describe '#show' do
    before(:example) do
      get :show, id: @list.to_param
    end

    it 'loads successfully' do
      expect(response).to be_success
    end
  end

  describe '#edit' do
    before(:example) do
      get :edit, id: @list.to_param
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'has a textarea field for the list' do
      expect(response.body).to have_selector('textarea[name="documents_stop_list[list]"]')
    end
  end
end
