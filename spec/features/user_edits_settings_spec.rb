require 'spec_helper'

RSpec.feature 'User edits their account settings', type: :feature do
  scenario 'when logged in' do
    sign_in_with

    within('.navbar-right') { click_link 'My Account' }
    fill_in 'user_email', with: 'new@example.com'
    fill_in 'user_current_password', with: 'changeme'
    click_button 'Update settings'

    expect(page).to have_content('Your account has been updated successfully.')
  end
end
