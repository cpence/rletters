# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "datasets/show" do
  
  login_user
  
  before(:each) do
    @dataset = FactoryGirl.create(:full_dataset, :entries_count => 10)
    assign(:dataset, @dataset)    
    params[:id] = @dataset.to_param
  end
  
  it 'shows the number of dataset entries' do
    render
    rendered.should contain('Number of documents: 10')
  end
  
  it 'shows the create-task markup' do
    render
    rendered.should contain('Export dataset as citations')
  end
  
  it "has a reference somewhere to the task list" do
    # Need to render the layout in order to get the page-JS
    render :template => 'datasets/show', :layout => 'layouts/application'
    rendered.should include(task_list_dataset_path(@dataset))
  end
  
end
