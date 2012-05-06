# -*- encoding : utf-8 -*-
require 'spec_helper'

SimpleCov.command_name 'spec:models' if defined?(SimpleCov) && RUBY_VERSION >= "1.9.0"

describe User do
  
  describe '#valid' do
    context 'when no identifier is specified' do
      before(:each) do
        @user = FactoryGirl.build(:user, :identifier => nil)
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when no name is specified' do
      before(:each) do
        @user = FactoryGirl.build(:user, :name => nil)
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when no email is specified' do
      before(:each) do
        @user = FactoryGirl.build(:user, :email => nil)
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when a duplicate email is specified' do
      before(:each) do
        @dupe = FactoryGirl.create(:user)
        @user = FactoryGirl.build(:user, :email => @dupe.email)
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when a bad email is specified' do
      before(:each) do
        @user = FactoryGirl.build(:user, :email => 'asdf-not-an-email.com')
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when a duplicate identifier is specified' do
      before(:each) do
        @dupe = FactoryGirl.create(:user)
        @user = FactoryGirl.build(:user, :identifier => @dupe.identifier)
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when a non-URL identifier is specified' do
      before(:each) do
        @user = FactoryGirl.build(:user, :identifier => 'thisisnotaurl')
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when a non-numeric per_page is specified' do
      before(:each) do
        @user = FactoryGirl.build(:user, :per_page => 'asdfasdf')
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when a non-integer per_page is specified' do
      before(:each) do
        @user = FactoryGirl.build(:user, :per_page => 3.14159)
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when a negative per_page is specified' do
      before(:each) do
        @user = FactoryGirl.build(:user, :per_page => -20)
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when per_page is zero' do
      before(:each) do
        @user = FactoryGirl.build(:user, :per_page => 0)
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when language is invalid' do
      before(:each) do
        @user = FactoryGirl.build(:user, :language => 'notalocaleCODE123')
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when all attributes are set correctly' do
      before(:each) do
        @user = FactoryGirl.create(:user)
      end
      
      it "is valid" do
        @user.should be_valid
      end
    end
  end
  
  describe '.find_or_initialize_with_rpx' do
    context 'when given an existing user in the database' do
      before(:each) do
        @db_user = FactoryGirl.create(:user)
        
        hash = {
          'name' => @db_user.name,
          'email' => @db_user.email,
          'identifier' => @db_user.identifier }
        @user = User.find_or_initialize_with_rpx(hash)        
      end
      
      it 'does not create a new record' do
        @user.should_not be_new_record
      end

      it 'is the same record' do
        @user.should eq(@db_user)
      end
    end
    
    context 'when given a new user not in the database' do
      before(:each) do
        hash = {
          'name' => 'New Guy',
          'email' => 'new@guy.com',
          'identifier' => 'https://newguy.com' }
        @user = User.find_or_initialize_with_rpx(hash)
      end
      
      it 'creates a new database record' do
        @user.should be_new_record
      end
    end
  end
  
end
