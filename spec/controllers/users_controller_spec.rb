# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UsersController do
  logout_user
  
  describe '#show' do
    it 'redirects to login' do
      get :show
      response.should redirect_to(login_user_path)
    end
  end
  
  describe '#login' do
    it 'loads successfully' do
      get :login
      response.should be_success
    end
  end
  
  describe '#create' do
    context 'when parameters are valid' do
      it 'creates a user' do
        expect {
          post :create, :user => { :name => 'New User Test', :email => 'new@user.com', :identifier => 'https://newuser.com', :per_page => 10, :language => 'es-MX' }
        }.to change{User.count}.by(1)
      end

      it 'redirects to the datasets page' do
        post :create, :user => { :name => 'New User Test', :email => 'new@user.com', :identifier => 'https://newuser.com', :per_page => 10, :language => 'es-MX' }
        response.should redirect_to(datasets_path)
      end

      it 'sets the session parameter' do
        post :create, :user => { :name => 'New User Test', :email => 'new@user.com', :identifier => 'https://newuser.com', :per_page => 10, :language => 'es-MX' }
        session.should include(:user_id)
      end

      it 'sets the user' do
        post :create, :user => { :name => 'New User Test', :email => 'new@user.com', :identifier => 'https://newuser.com', :per_page => 10, :language => 'es-MX' }
        assigns(:user).should be
      end
    end
    
    context 'when parameters are invalid' do
      it 'does not create a user' do
        expect {
          post :create, :user => { :name => 'New User Test', :email => 'this isabademail', :identifier => 'notaurl' }
        }.to_not change{User.count}
      end
      
      it 'loads successfully' do
        post :create, :user => { :name => 'New User Test', :email => 'this isabademail', :identifier => 'notaurl' }
        response.should be_success
      end
    end
  end
  
  describe '#update' do
    context 'when not logged in' do
      it 'redirects to index' do
        post :update, :id => '12345', :user => { :name => 'Not Johns Name', :email => 'jdoe@gmail.com' }
        response.should redirect_to(user_path)
      end
    end
    
    context 'when logged in' do
      login_user

      context 'when parameters are valid' do
        it 'updates the user without errors' do
          post :update, :id => @user.to_param, :user => { :name => 'Not Johns Name', :email => 'jdoe@gmail.com' }
          @user.errors.should have(0).items
        end

        it 'saves the updated data' do
          post :update, :id => @user.to_param, :user => { :name => 'Not Johns Name', :email => 'jdoe@gmail.com' }
          @user.reload
          @user.name.should eq("Not Johns Name")
        end
      end

      context 'when parameters are invalid' do
        it 'does not change the parameters' do
          expect {
            post :update, :id => @user, :user => { :name => 'John Doe', :email => 'thisisnotan.email' }
          }.to_not change{@user.email}
        end
      end
    end
  end
  
  describe '#rpx' do
    it 'does not load without RPX connection live' do
      stub_request(:any, /.*[.\/]rpxnow\.com.*/)
      expect {
        get :rpx
      }.to raise_error
    end
  end
  
  describe '#logout' do
    context 'when not logged in' do
      it 'redirects to index' do
        get :logout
        response.should redirect_to(user_path)
      end
    end
    
    context 'when logged in' do
      login_user
      
      it 'clears the user variable' do
        get :logout
        assigns(:user).should_not be
      end
      
      it 'clears the session parameter' do
        get :logout
        session.should_not include(:user_id)
      end
      
      it 'redirects to the root' do
        get :logout
        response.should redirect_to(root_url)
      end
    end
  end
  
end
