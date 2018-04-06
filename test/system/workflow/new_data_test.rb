require 'application_system_test_case'

class NewDataTest < ApplicationSystemTestCase
  test 'workflow with one new dataset' do
    # FIXME: perform_enqueued
    sign_in_with

    visit root_path
    click_link 'Start a new analysis'
    click_link 'When were a given set of articles published?'
    first(:link, 'Start', exact: true).click

    click_link 'Create another dataset'
    create_dataset

    click_link 'Current Analysis'

    click_link 'Set Job Options'
    click_button 'Start analysis job'

    within('.navbar') { click_link 'Fetch' }
    assert_selector 'td', text: 'Integration Dataset'

    click_link 'View'
    assert has_link?('Download in CSV format')
  end
end
