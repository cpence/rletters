require 'spec_helper'

RSpec.feature 'Viewing information about a dataset', type: :feature do
  scenario 'when viewing basic information' do
    sign_in_with
    create_dataset
    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')

    click_link 'Manage'

    expect(page).to have_content('Number of documents: 427')

    expect(page).to have_selector('div#dataset-task-list')
    expect(page).to have_selector('div#dataset-task-list table.button-table')

    expect(page).to have_selector('td', text: 'No analysis tasks found')
  end

  scenario 'when an analysis task is pending' do
    sign_in_with
    create_dataset
    visit datasets_path

    # We don't normally directly touch the database, but we're here mocking the
    # way that an external Redis/Resque task would have acted.
    create(:task, dataset: Dataset.first, resque_key: 'asdf123',
                  finished_at: nil)

    Resque::Plugins::Status::Hash.create(
      'asdf123',
      status: Resque::Plugins::Status::STATUS_WORKING,
      num: 40,
      total: 100,
      message: 'Pending task...'
    )

    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')
    click_link 'Manage'

    # It shouldn't have a failed task, and should warn you about a pending task
    expect(page).not_to have_selector('.alert.alert-danger')
    expect(page).to have_selector('.alert.alert-warning')
  end

  scenario 'when an analysis task has failed' do
    sign_in_with
    create_dataset
    visit datasets_path

    create(:task, dataset: Dataset.first, failed: true)

    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')
    click_link 'Manage'

    # It shouldn't have a pending task, and should have a failed task
    expect(page).not_to have_selector('.alert.alert-warning')
    expect(page).to have_selector('.alert.alert-danger')
  end

  scenario 'when clearing a failed analysis task' do
    sign_in_with
    create_dataset
    visit datasets_path

    create(:task, dataset: Dataset.first, failed: true)

    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')
    click_link 'Manage'

    expect(page).to have_content('Integration Dataset')
    click_link '1 analysis task failed for this dataset! Click here to clear failed tasks.'

    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')

    click_link 'Manage'
    expect(page).to have_content('Integration Dataset')

    expect(page).to have_selector('td', text: 'No analysis tasks found')
    expect(page).not_to have_selector('.alert.alert-danger')
  end

  scenario 'when an analysis task has finished' do
    sign_in_with
    create_dataset

    visit '/'
    click_link 'Start a new analysis'
    click_link 'When were a given set of articles published?'
    click_link 'Start'
    click_link 'Link an already created dataset'
    click_button 'Link dataset'
    click_link 'Set Job Options'
    click_button 'Start analysis job'

    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')
    click_link 'Manage'

    expect(page).to have_content('Integration Dataset')
    click_link 'View'

    expect(page).to have_content('Download in CSV format')

    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')
    click_link 'Manage'

    expect(page).to have_content('Integration Dataset')
    click_link 'Delete'

    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')
    click_link 'Manage'

    expect(page).to have_selector('td', text: 'No analysis tasks found')
    expect(page).not_to have_selector('.alert.alert-danger')
  end
end
