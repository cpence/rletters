require 'application_system_test_case'

class CitationStyleTest < ApplicationSystemTestCase
  test 'set a citation style' do
    sign_in_with

    style = FactoryBot.create(:csl_style)

    visit root_path
    within('.navbar') { click_link 'My Account' }
    select style.name, from: 'user_csl_style_id'
    fill_in 'user_current_password', with: 'changeme'
    click_button 'Update settings'

    assert_text 'Your account has been updated successfully.'

    visit '/search'
    fill_in 'q', with: 'test'
    find('#q').send_keys(:enter)

    assert_text 'Díaz, R., Casanova, A., Ariza, J. & Moriyón, I. The Rose Bengal Test in Human Brucellosis: A Neglected Test for the Diagnosis of a Neglected Disease. PLoS Neglected Tropical Diseases 5, e950 (2011).'
  end
end
