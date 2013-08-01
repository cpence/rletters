# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "datasets/dataset_list" do
  
  before(:each) do
    @user = FactoryGirl.create(:user)
    view.stub(:current_user) { @user }
    view.stub(:user_signed_in?) { true }

    @dataset = FactoryGirl.create(:full_dataset, :user => @user)
    assign(:datasets, [ @dataset ])
  end

  it 'lists the dataset' do
    render
    rendered.should have_tag('li', :text => /#{@dataset.name}\s+#{@dataset.entries.count}/)
  end
  
  it 'lists pending analysis tasks' do
    @task = FactoryGirl.create(:analysis_task, :dataset => @dataset)
    render
    
    rendered.should have_tag("li[data-theme=e]", :text => 'You have one analysis task pending...')
  end
  
  it 'does not list completed analysis tasks' do
    @task = FactoryGirl.create(:analysis_task, :dataset => @dataset, :finished_at => 5.minutes.ago)
    render
    
    rendered.should_not have_tag("li[data-theme=e]")
  end
  
end
