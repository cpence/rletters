# frozen_string_literal: true

module SystemAdminHelper
  def sign_out_admin
    visit '/admin'
    click_link 'Sign Out'
  end

  def sign_in_admin
    visit '/admin/login'
    fill_in 'password', with: 'password'
    click_button 'Log In'
  end
end
