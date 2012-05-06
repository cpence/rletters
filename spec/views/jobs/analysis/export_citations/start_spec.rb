# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "jobs/export_citations/start" do
  
  before(:each) do
    @dataset = FactoryGirl.create(:dataset)
  end
  
  it 'has links to all the document formats' do
    render
    
    Document.serializers.each do |k, v|
      link = url_for(:controller => 'datasets', :action => 'task_start', 
        :class => 'ExportCitations', :job_params => { :format => k }, 
        :id => @dataset.to_param)
      
      rendered.should have_selector("a[href='#{link}']")
    end
  end
  
end
