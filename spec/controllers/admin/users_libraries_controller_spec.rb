# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin::UsersLibrariesController do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:each) do
    @administrator = FactoryGirl.create(:administrator)
    sign_in :administrator, @administrator
    @library = FactoryGirl.create(:library)
  end

  describe '#index' do
    before(:each) do
      get :index
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'includes the URL' do
      expect(response.body).to include(@library.url)
    end

    it 'includes the user who created it' do
      expect(response.body).to include(@library.user.name)
    end
  end

end
