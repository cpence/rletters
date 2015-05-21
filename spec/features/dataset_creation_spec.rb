require 'spec_helper'

RSpec.feature 'Creating a dataset from a search', type: :feature do
  scenario 'when searching for articles' do
    sign_in_with
    create_dataset

    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')

    click_link 'Manage'
    expect(page).to have_content('Information for dataset — Integration Dataset')
  end
end
