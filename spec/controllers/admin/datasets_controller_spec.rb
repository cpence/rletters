# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe Admin::DatasetsController, type: :controller do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:example) do
    @administrator = create(:administrator)
    sign_in :administrator, @administrator
    @dataset = create(:dataset)
  end

  describe '#index' do
    before(:example) do
      get :index
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'includes the dataset' do
      expect(response.body).to include(@dataset.name)
    end

    it 'includes the user who created it' do
      expect(response.body).to include(@dataset.user.name)
    end

    it 'includes the number of entries' do
      expect(response.body).to include(@dataset.entries.size.to_s)
    end
  end

end
