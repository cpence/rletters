require 'application_system_test_case'

class AbortTest < ApplicationSystemTestCase
  test 'abort a partial workflow' do
    sign_in_with
    create_dataset

    visit root_path
    click_link 'Start a new analysis'
    click_link 'When were a given set of articles published?'
    first(:link, 'Start', exact: true).click

    click_link 'Link an already created dataset'
    within('.modal-dialog') do
      click_button 'Link dataset'
    end

    click_link 'Abort Building Analysis'

    visit root_path
    assert has_link?('Current Analysis')
  end
end
