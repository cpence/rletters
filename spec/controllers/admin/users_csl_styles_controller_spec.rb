require 'spec_helper'

RSpec.describe Admin::UsersCslStylesController, type: :controller do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:example) do
    @style = create(:csl_style)
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

    it 'includes the CSL style in the list' do
      expect(response.body).to include(@style.name)
    end
  end
end
