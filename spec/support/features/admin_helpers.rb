
module Features
  module AdminHelpers
    def sign_out_admin
      visit '/admin/sign_out'
    end

    def sign_in_admin
      sign_out_admin

      # These are always built by hand in the database anyway
      @admin = create(:administrator,
                      email: 'admin@example.com',
                      password: 'password',
                      password_confirmation: 'password')

      visit '/admin'
      fill_in 'administrator_email', with: 'admin@example.com'
      fill_in 'administrator_password', with: 'password'
      click_button 'Log in'
    end
  end
end
