require 'application_system_test_case'

class EditSettingsTest < ApplicationSystemTestCase
  test 'edit user settings' do
    sign_in_with

    within('.navbar-right') { click_link 'My Account' }
    fill_in 'user_email', with: 'new@example.com'
    fill_in 'user_current_password', with: 'changeme'
    click_button 'Update settings'

    assert_text 'Your account has been updated successfully.'
  end
end
