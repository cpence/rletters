require 'rails_helper'

RSpec.feature 'User signs into their account', type: :feature do
  scenario 'when I have no account' do
    sign_in_with({}, false)

    expect(page).to have_content(/Invalid [Ee]-?mail( address)? or password./)
    expect(page).to have_content('Sign In')
    expect(page).not_to have_content('Sign Out')
  end

  scenario 'with valid data' do
    sign_in_with

    expect(page).to have_content('Signed in successfully.')

    visit '/'
    expect(page).to have_content('Sign Out')
    expect(page).not_to have_content('Sign In')
  end
end
