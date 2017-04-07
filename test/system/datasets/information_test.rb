require 'application_system_test_case'

class InformationTest < ApplicationSystemTestCase
  test 'view basic information' do
    sign_in_with
    create_dataset
    visit datasets_path
    assert_selector 'td', text: 'Integration Dataset'

    click_link 'Manage'
    find('#dataset-task-list table')

    assert_text 'Number of documents: 427'
    assert_text 'Search type Normal search'
    assert_text 'Search query test'

    assert_selector 'div#dataset-task-list'
    assert_selector 'div#dataset-task-list table.button-table'
    assert_selector 'td', text: 'No tasks found'
  end

  test 'view a pending task' do
    sign_in_with
    create_dataset
    visit datasets_path

    create(:task, dataset: Dataset.first, finished_at: nil)

    visit datasets_path
    assert_selector 'td', text: 'Integration Dataset'

    click_link 'Manage'
    find('#dataset-task-list table')

    # It shouldn't have a failed task, and should warn you about a pending task
    assert_no_selector '.alert.alert-danger'
    assert_selector '.alert.alert-warning'
  end

  test 'view a failed task' do
    sign_in_with
    create_dataset
    visit datasets_path

    create(:task, dataset: Dataset.first, failed: true)

    visit datasets_path
    assert_selector 'td', text: 'Integration Dataset'

    click_link 'Manage'
    find('#dataset-task-list table')

    # It shouldn't have a pending task, and should have a failed task
    assert_no_selector '.alert.alert-warning'
    assert_selector '.alert.alert-danger'
  end

  test 'clear a failed task' do
    sign_in_with
    create_dataset
    visit datasets_path

    create(:task, dataset: Dataset.first, failed: true)

    visit datasets_path
    assert_selector 'td', text: 'Integration Dataset'

    click_link 'Manage'
    find('#dataset-task-list table')

    assert_text 'Integration Dataset'
    click_link '1 task failed for this dataset! Click here to clear failed tasks.'

    visit datasets_path
    assert_selector 'td', text: 'Integration Dataset'

    click_link 'Manage'
    assert_text 'Integration Dataset'

    assert_selector 'td', text: 'No tasks found'
    assert_no_selector '.alert.alert-danger'
  end

  test 'view a finished task' do
    # FIXME: perform_enqueued
    sign_in_with
    create_dataset

    visit '/'
    click_link 'Start a new analysis'
    click_link 'When were a given set of articles published?'
    first(:link, 'Start', exact: true).click
    click_link 'Link an already created dataset'
    click_button 'Link dataset'
    click_link 'Set Job Options'

    click_button 'Start analysis job'

    visit datasets_path
    assert_selector 'td', text: 'Integration Dataset'

    click_link 'Manage'
    find('#dataset-task-list table')

    assert_text 'Integration Dataset'
    click_link 'View'

    assert_text 'Download in CSV format'

    visit datasets_path
    assert_selector 'td', text: 'Integration Dataset'

    click_link 'Manage'
    find('#dataset-task-list table')

    assert_text 'Integration Dataset'
    click_link 'Delete'

    visit datasets_path
    assert_selector 'td', text: 'Integration Dataset'

    click_link 'Manage'
    find('#dataset-task-list table')

    assert_selector 'td', text: 'No tasks found'
    assert_no_selector '.alert.alert-danger'
  end
end
