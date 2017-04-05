require 'rails_helper'

RSpec.feature 'User sets a custom citation style', type: :feature do
  scenario 'when logged in' do
    sign_in_with

    style = FactoryGirl.create(:csl_style)

    visit root_path
    within('.navbar-right') { click_link 'My Account' }
    select style.name, from: 'user_csl_style_id'
    fill_in 'user_current_password', with: 'changeme'
    click_button 'Update settings'

    expect(page).to have_content('Your account has been updated successfully.')

    visit '/search'
    fill_in 'q', with: 'test'
    find('#q').send_keys(:enter)

    expect(page).to have_content('Díaz, R., Casanova, A., Ariza, J. & Moriyón, I. The Rose Bengal Test in Human Brucellosis: A Neglected Test for the Diagnosis of a Neglected Disease. PLoS Neglected Tropical Diseases 5, e950 (2011).')
  end
end
