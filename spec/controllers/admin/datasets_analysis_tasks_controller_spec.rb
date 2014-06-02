# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe Admin::DatasetsAnalysisTasksController, type: :controller do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:example) do
    @administrator = create(:administrator)
    sign_in :administrator, @administrator
    @task = create(:analysis_task)
  end

  describe '#index' do
    before(:example) do
      get :index
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'includes the analysis task' do
      expect(response.body).to include(@task.name)
    end
  end

end
