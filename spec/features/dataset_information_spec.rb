require 'rails_helper'

RSpec.feature 'Viewing information about a dataset', type: :feature do
  scenario 'when viewing basic information' do
    sign_in_with
    create_dataset
    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')

    click_link 'Manage'
    find('#dataset-task-list table')

    expect(page).to have_content('Number of documents: 427')
    expect(page).to have_content('Search type Normal search')
    expect(page).to have_content('Search query test')

    expect(page).to have_selector('div#dataset-task-list')
    expect(page).to have_selector('div#dataset-task-list table.button-table')
    expect(page).to have_selector('td', text: 'No tasks found')
  end

  scenario 'when a task is pending' do
    sign_in_with
    create_dataset
    visit datasets_path

    create(:task, dataset: Dataset.first, finished_at: nil)

    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')

    click_link 'Manage'
    find('#dataset-task-list table')

    # It shouldn't have a failed task, and should warn you about a pending task
    expect(page).not_to have_selector('.alert.alert-danger')
    expect(page).to have_selector('.alert.alert-warning')
  end

  scenario 'when a task has failed' do
    sign_in_with
    create_dataset
    visit datasets_path

    create(:task, dataset: Dataset.first, failed: true)

    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')

    click_link 'Manage'
    find('#dataset-task-list table')

    # It shouldn't have a pending task, and should have a failed task
    expect(page).not_to have_selector('.alert.alert-warning')
    expect(page).to have_selector('.alert.alert-danger')
  end

  scenario 'when clearing a failed task' do
    sign_in_with
    create_dataset
    visit datasets_path

    create(:task, dataset: Dataset.first, failed: true)

    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')

    click_link 'Manage'
    find('#dataset-task-list table')

    expect(page).to have_content('Integration Dataset')
    click_link '1 task failed for this dataset! Click here to clear failed tasks.'

    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')

    click_link 'Manage'
    expect(page).to have_content('Integration Dataset')

    expect(page).to have_selector('td', text: 'No tasks found')
    expect(page).not_to have_selector('.alert.alert-danger')
  end

  scenario 'when a task has finished', perform_enqueued: true do
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
    expect(page).to have_selector('td', text: 'Integration Dataset')

    click_link 'Manage'
    find('#dataset-task-list table')

    expect(page).to have_content('Integration Dataset')
    click_link 'View'

    expect(page).to have_content('Download in CSV format')

    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')

    click_link 'Manage'
    find('#dataset-task-list table')

    expect(page).to have_content('Integration Dataset')
    click_link 'Delete'

    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')

    click_link 'Manage'
    find('#dataset-task-list table')

    expect(page).to have_selector('td', text: 'No tasks found')
    expect(page).not_to have_selector('.alert.alert-danger')
  end
end
