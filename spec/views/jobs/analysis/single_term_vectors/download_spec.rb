# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "jobs/single_term_vectors/download" do

  before(:each) do
    # RSpec isn't smart enough to read our routes for us, so set
    # things manually here.
    controller.controller_path = "datasets"
    controller.request.path_parameters[:controller] = "datasets"

    @dataset = FactoryGirl.create(:dataset)
    @task = FactoryGirl.create(:analysis_task, name: "Term frequency information",
                               job_type: 'SingleTermVectors', dataset: @dataset)
    @task.result_file = Download.create_file('temp.yml') do |file|
      file.write({ test: { tf: 3, df: 1, tfidf: 2.5 }}.with_indifferent_access.to_yaml)
      file.close
    end
    @task.save
  end

  after(:each) do
    @task.destroy
  end

  it "shows a header column" do
    render
    rendered.should =~ /Term,tf,df,tf\*idf/
  end

  it 'shows the data in a CSV row' do
    render
    rendered.should =~ /test,3,1,2\.5/
  end
end
