
module SystemAdminHelper
  def sign_out_admin
    visit '/admin/sign_out'
  end

  def sign_in_admin
    sign_out_admin

    # The username and password for this administrator are seeded in the DB
    visit '/admin'
    fill_in 'administrator_email', with: 'admin@example.com'
    fill_in 'administrator_password', with: 'password'
    click_button 'Log in'
  end
end
