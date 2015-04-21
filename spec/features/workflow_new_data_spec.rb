require 'spec_helper'

RSpec.feature 'User runs workflow on a new dataset', type: :feature do
  scenario 'when linking one dataset' do
    sign_in_with

    visit root_path
    click_link 'Start a new analysis'
    click_link 'When were a given set of articles published?'
    click_link 'Start'

    click_link 'Create another dataset'
    create_dataset

    click_link 'Current Analysis'
    click_link 'Set Job Options'
    click_button 'Start analysis job'

    within('.navbar') { click_link 'Fetch' }
    expect(page).to have_selector('td', text: 'Integration Dataset')

    click_link 'View'
    expect(page).to have_link('Download in CSV format')
  end
end
