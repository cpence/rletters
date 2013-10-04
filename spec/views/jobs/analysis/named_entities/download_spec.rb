# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'named_entities/download' do

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

  it 'shows a header column' do
    render
    expect(rendered).to match(/Type,Hit/)
  end

  it 'shows all types of data' do
    render
    expect(rendered).to match(/ORGANIZATION,Princeton University/)
    expect(rendered).to match(/PERSON,Albert Einstein/)
    expect(rendered).to match(/LOCATION,"Austin, Texas"/)
  end
end
