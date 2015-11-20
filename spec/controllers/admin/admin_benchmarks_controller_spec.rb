require 'rails_helper'

RSpec.describe Admin::AdminBenchmarksController, type: :controller do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:example) do
    @administrator = create(:administrator)
    sign_in :administrator, @administrator
    @benchmark = create(:benchmark)
  end

  describe '#index' do
    before(:example) do
      get :index
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'includes the benchmark' do
      expect(response.body).to include(@benchmark.job)
    end

    it 'includes the dataset size' do
      expect(response.body).to include(@benchmark.size.to_s)
    end

    it 'includes the benchmark time' do
      expect(response.body).to include(@benchmark.time.to_s)
    end
  end
end
