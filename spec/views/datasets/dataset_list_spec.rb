# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "datasets/dataset_list" do
  
  login_user
  before(:each) do
    @dataset = FactoryGirl.create(:full_dataset, :user => @user)
    assign(:datasets, [ @dataset ])
  end

  it 'lists the dataset' do
    render
    rendered.should contain("#{@dataset.name} #{@dataset.entries.count}")
  end
  
  it 'lists pending analysis tasks' do
    @task = FactoryGirl.create(:analysis_task, :dataset => @dataset)
    render
    
    rendered.should have_selector("li[data-theme=e]", :content => 'You have one analysis task pending...')
  end
  
  it 'does not list completed analysis tasks' do
    @task = FactoryGirl.create(:analysis_task, :dataset => @dataset, :finished_at => 5.minutes.ago)
    render
    
    rendered.should_not have_selector("li[data-theme=e]")
  end
  
end
