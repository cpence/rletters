require 'spec_helper'

RSpec.feature 'User fetching a pending task', type: :feature do
  scenario 'when task is not finished' do
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

    within('.navbar') { click_link 'Fetch' }
    expect(page).to have_selector('td', text: '40%: Pending task...')
  end
end
