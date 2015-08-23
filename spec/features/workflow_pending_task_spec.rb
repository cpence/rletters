require 'rails_helper'

RSpec.feature 'User fetching a pending task', type: :feature do
  scenario 'when task is not finished' do
    sign_in_with
    create_dataset
    visit datasets_path

    create(:task, dataset: Dataset.first, finished_at: nil,
                  progress: 0.4, progress_message: 'Pending task...')

    within('.navbar') { click_link 'Fetch' }
    expect(page).to have_selector('td', text: '40%: Pending task...')
  end
end
