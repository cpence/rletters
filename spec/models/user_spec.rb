# -*- encoding : utf-8 -*-
require 'spec_helper'

SimpleCov.command_name 'spec:models' if defined?(SimpleCov)

describe User do

  describe '#valid' do
    context 'when no name is specified' do
      before(:each) do
        @user = FactoryGirl.build(:user, name: nil)
      end

      it "isn't valid" do
        @user.should_not be_valid
      end
    end

    context 'when no email is specified' do
      before(:each) do
        @user = FactoryGirl.build(:user, email: nil)
      end

      it "isn't valid" do
        @user.should_not be_valid
      end
    end

    context 'when a duplicate email is specified' do
      before(:each) do
        @dupe = FactoryGirl.create(:user)
        @user = FactoryGirl.build(:user, email: @dupe.email)
      end

      it "isn't valid" do
        @user.should_not be_valid
      end
    end

    context 'when a bad email is specified' do
      before(:each) do
        @user = FactoryGirl.build(:user, email: 'asdf-not-an-email.com')
      end

      it "isn't valid" do
        @user.should_not be_valid
      end
    end

    context 'when a non-numeric per_page is specified' do
      before(:each) do
        @user = FactoryGirl.build(:user, per_page: 'asdfasdf')
      end

      it "isn't valid" do
        @user.should_not be_valid
      end
    end

    context 'when a non-integer per_page is specified' do
      before(:each) do
        @user = FactoryGirl.build(:user, per_page: 3.14159)
      end

      it "isn't valid" do
        @user.should_not be_valid
      end
    end

    context 'when a negative per_page is specified' do
      before(:each) do
        @user = FactoryGirl.build(:user, per_page: -20)
      end

      it "isn't valid" do
        @user.should_not be_valid
      end
    end

    context 'when per_page is zero' do
      before(:each) do
        @user = FactoryGirl.build(:user, per_page: 0)
      end

      it "isn't valid" do
        @user.should_not be_valid
      end
    end

    context 'when language is invalid' do
      before(:each) do
        @user = FactoryGirl.build(:user, language: 'notalocaleCODE123')
      end

      it "isn't valid" do
        @user.should_not be_valid
      end
    end

    context 'when all attributes are set correctly' do
      before(:each) do
        @user = FactoryGirl.create(:user)
      end

      it 'is valid' do
        @user.should be_valid
      end
    end
  end

end
