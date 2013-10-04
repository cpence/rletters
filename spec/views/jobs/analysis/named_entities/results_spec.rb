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
    ios.write(@data.to_json)
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

  it 'links to the PERSONs on Wikipedia' do
    render

    expected = "https://en.wikipedia.org/w/index.php?title=Special:Search&amp;search=Albert+Einstein&amp;fulltext=Search"
    expect(rendered).to include(expected)
  end

  it 'links to the ORGANIZATIONs on Wikipedia' do
    render

    expected = "https://en.wikipedia.org/w/index.php?title=Special:Search&amp;search=Princeton+University&amp;fulltext=Search"
    expect(rendered).to include(expected)
  end

  it 'links to the LOCATIONs on Wikipedia' do
    render

    expected = "https://en.wikipedia.org/w/index.php?title=Special:Search&amp;search=Austin%2C+Texas&amp;fulltext=Search"
    expect(rendered).to include(expected)
  end

  it 'leaves the map data in the HTML' do
    render

    expected = "[&quot;Austin, Texas&quot;]"
    expect(rendered).to include(expected)
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
