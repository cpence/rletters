require 'spec_helper'

RSpec.feature 'User adds links to their own libraries', type: :feature do
  scenario 'when adding automatically' do
    sign_in_with

    visit root_path
    within('.navbar-right') { click_link 'My Account' }

    stub_connection(/worldcat.org/, 'worldcat_notre_dame')
    click_link 'Look up your library automatically'
    find('.modal-dialog')

    click_button 'University of NotreDame'

    visit libraries_path
    expect(page).to have_selector('td', text: 'University of NotreDame')

    visit search_path
    find_link 'Your library: University of NotreDame', match: :first, visible: false
  end

  scenario 'when adding manually' do
    sign_in_with

    visit root_path
    within('.navbar-right') { click_link 'My Account' }

    click_link('Add your library manually')
    find('.modal-dialog')

    fill_in 'users_library_name', with: 'Harvard'
    fill_in 'users_library_url', with: 'http://library.harvard.edu/?'
    click_button 'Create Library'

    visit libraries_path
    expect(page).to have_selector('td', text: 'Harvard')

    visit search_path
    find_link 'Your library: Harvard', match: :first, visible: false
  end
end
