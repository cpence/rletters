# frozen_string_literal: true
require 'application_system_test_case'

class LinkLibrariesTest < ApplicationSystemTestCase
  test 'link library automatically' do
    sign_in_with

    visit root_path
    within('.navbar') { click_link 'My Account' }

    stub_connection(/worldcat.org/, 'worldcat_notre_dame')
    click_link 'Look up your library automatically'
    find('.modal-dialog')

    click_button 'University of NotreDame'

    visit libraries_path
    assert_selector 'td', text: 'University of NotreDame'

    visit search_path
    find_link 'Your library: University of NotreDame', match: :first, visible: false
  end

  test 'link library manually' do
    sign_in_with

    visit root_path
    within('.navbar') { click_link 'My Account' }

    click_link('Add your library manually')
    find('.modal-dialog')

    fill_in 'users_library_name', with: 'Harvard'
    fill_in 'users_library_url', with: 'http://library.harvard.edu/?'
    click_button 'Create Library'

    visit libraries_path
    assert_selector 'td', text: 'Harvard'

    visit search_path
    find_link 'Your library: Harvard', match: :first, visible: false
  end
end
