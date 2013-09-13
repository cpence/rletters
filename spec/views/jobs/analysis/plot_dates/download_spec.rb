# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'plot_dates/download' do

  before(:each) do
    register_job_view_path

    @dataset = FactoryGirl.create(:full_dataset)
    @task = FactoryGirl.create(:analysis_task,
                               name: 'Plot dataset by date',
                               job_type: 'PlotDates',
                               dataset: @dataset)
    @task.result_file = Download.create_file('temp.yml') do |file|
      file.write([[2003, 13]].to_yaml)
      file.close
    end
    @task.save
  end

  after(:each) do
    @task.destroy
  end

  it 'shows a header column' do
    render
    expect(rendered).to match(/Year,Number of Documents/)
  end

  it 'shows the year and count in a CSV row' do
    render
    expect(rendered).to match(/2003,13/)
  end
end
