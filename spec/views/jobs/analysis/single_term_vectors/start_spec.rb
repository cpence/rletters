# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "jobs/single_term_vectors/start" do
  
  context "when dataset has one document" do
    before(:each) do
      @dataset = FactoryGirl.create(:full_dataset, :entries_count => 1)
    end

    it 'has a link to start the task' do
      render
    
      link = url_for(:controller => 'datasets', :action => 'task_start', 
        :class => 'SingleTermVectors', :id => @dataset.to_param)
      rendered.should have_selector("a[href='#{link}']")
    end
  end
  
  context "when dataset has more than one document" do
    before(:each) do
      @dataset = FactoryGirl.create(:full_dataset)
    end
    
    it 'does not have a link to start the task' do
      render
      rendered.should_not have_selector("a")
    end
  end
  
end
