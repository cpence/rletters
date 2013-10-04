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
    ios = StringIO.new
    ios.write({ data: [[2003, 13]], percent: false, normalization_set: nil }.to_json)
    ios.original_filename = 'temp.json'
    ios.content_type = 'application/json'
    ios.rewind

    @task.result = ios
    ios.close
    @task.save
  end

  after(:each) do
    @task.destroy
  end

  it 'shows a header column for a non-normalized file' do
    render
    expect(rendered).to match(/Year,Number of Documents/)
  end

  it 'shows the year and count in a CSV row' do
    render
    expect(rendered).to match(/2003,13/)
  end
end
