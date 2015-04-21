require 'spec_helper'

RSpec.feature 'User signs up for an account', type: :feature do
  scenario 'with valid data' do
    sign_up_with

    expect(page).to have_content('You have signed up successfully.')
  end

  scenario 'with invalid e-mail' do
    sign_up_with(email: 'notanemail')

    expect(page).to have_selector('.user_email.has-error')
  end

  scenario 'with mismatched password and confirmation' do
    sign_up_with(password_confirmation: 'changeme123')

    expect(page).to have_selector('.user_password_confirmation.has-error .help-block',
                                  text: "doesn't match Password")
  end

  scenario 'requesting a foreign language' do
    page.driver.header('Accept-Language', 'es, en')

    sign_up_with

    visit '/users/edit'
    expect(page).to have_select('user[language]', selected: 'español')
  end
end
