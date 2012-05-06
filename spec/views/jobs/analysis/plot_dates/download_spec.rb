# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "jobs/plot_dates/download" do
  
  before(:each) do
    @dataset = FactoryGirl.create(:full_dataset)
    @task = FactoryGirl.create(:analysis_task, :name => "Plot dataset by date",
                               :job_type => 'PlotDates', :dataset => @dataset)
    @task.result_file = Download.create_file('temp.yml') do |file|
      file.write([ [ 2003, 13 ] ].to_yaml)
      file.close
    end
    @task.save
  end
  
  after(:each) do
    @task.destroy
  end
  
  it "shows a header column" do
    render
    rendered.should contain("Year,Number of Documents")
  end
  
  it 'shows the year and count in a CSV row' do
    render
    rendered.should contain("2003,13")
  end
end
