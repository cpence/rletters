# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'craig_zeta/download' do

  before(:each) do
    register_job_view_path

    @user = FactoryGirl.create(:user)
    allow(view).to receive(:current_user).and_return(@user)
    @dataset = FactoryGirl.create(:full_dataset, user: @user)
    @dataset_2 = FactoryGirl.create(:full_dataset, user: @user)

    @task = FactoryGirl.create(:analysis_task,
                               name: 'Differentiate two datasets (Craig Zeta)',
                               job_type: 'CraigZeta',
                               dataset: @dataset)

    data = {
      name_1: 'Dataset 1',
      name_2: 'Dataset 2',
      marker_words: ['totallyone', 'yepitsnumberone'],
      anti_marker_words: ['definitelytwo', 'reallynotnumberone'],
      graph_points: [['Dataset 1: Block 1', 0.2, 0.2], ['Dataset 2: Block 1', 0.8, 0.8]],
      zeta_scores: { 'totallyone' => 1.8, 'yepitsnumberone' => 1.3, 'definitelytwo' => 0.2, 'reallynotnumberone' => 0.3 }
    }

    ios = StringIO.new
    ios.write(data.to_json)
    ios.original_filename = 'craig_zeta.json'
    ios.content_type = 'application/json'
    ios.rewind

    @task.result = ios
    ios.close
    @task.save
  end

  after(:each) do
    @task.destroy
  end

  it 'has rows for the graph points' do
    render
    expect(rendered).to match(/Dataset 1: Block 1,0\.2,0\.2/)
  end

  it 'has rows for the Zeta scores' do
    render
    expect(rendered).to match(/totallyone,1\.8/)
  end
end
