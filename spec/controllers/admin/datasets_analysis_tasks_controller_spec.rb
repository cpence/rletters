# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin::DatasetsAnalysisTasksController do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:each) do
    @administrator = FactoryGirl.create(:administrator)
    sign_in :administrator, @administrator
    @task = FactoryGirl.create(:analysis_task)
  end

  describe '#index' do
    before(:each) do
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
