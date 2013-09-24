# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'named_entities/results', :nlp do

  before(:each) do
    register_job_view_path

    @dataset = FactoryGirl.create(:full_dataset)
    @task = FactoryGirl.create(:analysis_task,
                               name: 'Extract named entity references',
                               job_type: 'NamedEntites',
                               dataset: @dataset)
    @data = {
      'ORGANIZATION' => ['Princeton University', 'NSF'],
      'PERSON' => ['Albert Einstein'],
      'LOCATION' => ['Austin, Texas']
    }
    ios = StringIO.new
    ios.write(@data.to_yaml)
    ios.original_filename = 'temp.yml'
    ios.content_type = 'text/x-yaml'
    ios.rewind

    @task.result = ios
    ios.close
    @task.save
  end

  after(:each) do
    @task.destroy
  end

  it 'drops the data into the HTML file' do
    render

    # This is hard to match for, but this regex should work
    expected = /&quot;ORGANIZATION&quot;.*&quot;Princeton University&quot/
    expect(rendered).to match(expected)
  end

  # it 'has a link to download the results as CSV' do
  #   render

  #   expected = url_for(controller: 'datasets',
  #                      action: 'task_view',
  #                      id: @dataset.to_param,
  #                      task_id: @task.to_param,
  #                      view: 'download',
  #                      format: 'csv')
  #   expect(rendered).to have_tag("a[href='#{expected}']")
  # end

end
