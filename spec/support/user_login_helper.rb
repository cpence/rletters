# -*- encoding : utf-8 -*-

module UserLoginHelper
  def login_user(attributes = {})
    before(:each) do
      @user = FactoryGirl.create(:user, attributes)
      session[:user_id] = @user.to_param
    end

    after(:each) do
      @user = nil
      session[:user_id] = nil
    end
  end

  def logout_user
    before(:each) do
      @user = nil
      session[:user_id] = nil
    end
  end
end

