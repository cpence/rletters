require 'spec_helper'

RSpec.feature 'User signs out of their account', type: :feature do
  scenario 'when logged in' do
    sign_in_with
    sign_out

    expect(page).to have_content('Signed out successfully.')

    visit '/'
    expect(page).to have_content('Sign In')
    expect(page).not_to have_content('Sign Out')
  end
end
