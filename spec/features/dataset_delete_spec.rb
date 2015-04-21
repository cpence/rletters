require 'spec_helper'

RSpec.feature 'Deleting a dataset', type: :feature do
  scenario 'when deleting a dataset' do
    sign_in_with
    create_dataset

    visit datasets_path
    expect(page).to have_selector('td', text: "Integration Dataset")

    click_link 'Delete'

    expect(page).to have_selector('td', text: 'No datasets')
  end
end
