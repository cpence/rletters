# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'plot_dates/results' do

  before(:each) do
    register_job_view_path

    @dataset = FactoryGirl.create(:full_dataset)
    @task = FactoryGirl.create(:analysis_task,
                               name: 'Plot dataset by date',
                               job_type: 'PlotDates',
                               dataset: @dataset)
    @task.result_file = Download.create_file('temp.yml') do |file|
      file.write({ data: [[2003, 13]], percent: false, normalization_set: nil }.to_yaml)
      file.close
    end
    @task.save
  end

  after(:each) do
    @task.destroy
  end

  it 'drops the data into the HTML file' do
    render

    expect(rendered).to have_tag('div.plot_dates_data', text: '[[2003, 13]]')
    expect(rendered).to have_tag('div.plot_dates_percent', text: 'false')
  end

  it 'has a link to download the results as CSV' do
    render

    expected = url_for(controller: 'datasets',
                       action: 'task_view',
                       id: @dataset.to_param,
                       task_id: @task.to_param,
                       view: 'download',
                       format: 'csv')
    expect(rendered).to have_tag("a[href='#{expected}']")
  end

end
