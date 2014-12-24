require 'spec_helper'

RSpec.describe Admin::DocumentsCategoriesController, type: :controller do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:example) do
    @category = create(:category)
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

    it 'includes one of the categories' do
      expect(response.body).to include(@category.name)
    end
  end

  describe '#show' do
    before(:example) do
      get :show, id: @category.to_param
    end

    it 'loads successfully' do
      expect(response).to be_success
    end
  end

  describe '#edit' do
    before(:example) do
      get :edit, id: @category.to_param
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'has checkboxes for the journals' do
      expect(response.body).to have_selector('input#documents_category_journals_plos_neglected_tropical_diseases[name="documents_category[journals][]"]')
    end
  end
end
