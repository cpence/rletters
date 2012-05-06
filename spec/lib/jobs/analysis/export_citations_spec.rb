# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'zip/zip'

describe Jobs::Analysis::ExportCitations do

  it_should_behave_like 'an analysis job with a file' do
    let(:job_params) { { :format => :bibtex } }
  end
  
  before(:each) do
    @user = FactoryGirl.create(:user)
    @dataset = FactoryGirl.create(:full_dataset, :entries_count => 10,
                                  :working => true, :user => @user)
  end
  
  context "when an invalid format is specified" do
    it "raises an exception" do
      expect {
        Jobs::Analysis::ExportCitations.new(:user_id => @user.to_param,
                                            :dataset_id => @dataset.to_param,
                                            :format => :notaformat).perform
      }.to raise_error(ArgumentError)
    end
  end
  
  context "when the format is a string" do
    it "works anyway" do
      expect {
        Jobs::Analysis::ExportCitations.new(:user_id => @user.to_param,
                                            :dataset_id => @dataset.to_param,
                                            :format => 'bibtex').perform
      }.to_not raise_error
    end
  end
  
  context "when all parameters are valid" do
    before(:each) do
      Jobs::Analysis::ExportCitations.new(:user_id => @user.to_param,
                                          :dataset_id => @dataset.to_param,
                                          :format => :bibtex).perform
    end
    
    after(:each) do
      @dataset.analysis_tasks[0].destroy
    end
    
    it "names the task correctly" do
      @dataset.analysis_tasks[0].name.should eq("Export as BibTeX")
    end
    
    it "creates a proper ZIP file" do
      Zip::ZipFile.open(@dataset.analysis_tasks[0].result_file.filename) do |zf|
        zf.should have(10).entry
      end
    end
  end
  
end
