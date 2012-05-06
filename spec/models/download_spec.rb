# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Download do
  
  describe '#valid?' do
    context 'when no filename specified' do
      before(:each) do
        @dl = FactoryGirl.build(:download, :filename => nil)
      end
      
      it "isn't valid" do
        @dl.should_not be_valid
      end
    end
    
    context "when filename with path specified" do
      before(:each) do
        @dl = FactoryGirl.build(:download, :filename => '../../../hax/lol.wut')
      end
      
      it "isn't valid" do
        @dl.should_not be_valid
      end
    end
    
    context 'when filename specified' do
      before(:each) do
        @dl = FactoryGirl.build(:download)
      end
      
      it "is valid" do
        @dl.should be_valid
      end
    end
    
    context "when filename has dashes and underscores" do
      before(:each) do
        @dl = FactoryGirl.build(:download, :filename => 'a-b_c.wut')
      end
      
      it "is valid" do
        @dl.should be_valid
      end
    end
  end
  
  describe '.create_file' do
    before(:each) do
      @dl = Download.create_file 'test.txt' do |f|
        f.write('1234567890')
      end
    end
    
    context 'when created' do
      after(:each) do
        @dl.destroy
      end
      
      it "is successful" do
        @dl.should be
      end
      
      it "creates the file" do
        File.exists?(@dl.filename).should be_true
      end
      
      it "has the right contents" do
        IO.read(@dl.filename).should eq('1234567890')
      end
    end
    
    context 'when destroyed' do
      it "deletes the file" do
        filename = @dl.filename
        @dl.destroy
        
        File.exists?(filename).should be_false
      end
    end

    context 'when many are created simultaneously' do
      it "successfully creates unique filenames" do
        files = (1..25).map do
          Download.create_file 'test.txt' do |f|
            f.write("asdf")
          end
        end
        filenames = files.map { |f| f.filename }
        filenames.uniq!.should be_nil

        files.each { |f| f.destroy }
      end
    end
  end

end
