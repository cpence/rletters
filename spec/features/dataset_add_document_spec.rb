require 'spec_helper'

RSpec.feature 'Adding a dataset to a search', type: :feature do
  scenario 'when adding a single article' do
    sign_in_with
    create_dataset

    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')
    click_link 'Manage'

    expect(page).to have_content('Number of documents: 427')

    visit search_path
    first(:button, 'More').click
    click_link 'Add this document to an existing dataset'

    within('.modal-dialog') do
      click_button 'Add'
    end

    visit datasets_path
    expect(page).to have_selector('td', text: 'Integration Dataset')
    click_link 'Manage'

    expect(page).to have_content('Number of documents: 428')
  end
end
