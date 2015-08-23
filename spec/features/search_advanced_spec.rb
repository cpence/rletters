require 'rails_helper'

RSpec.feature 'Searching on the advanced page', type: :feature do
  scenario 'when searching for an author' do
    visit '/search/advanced'
    select 'Authors', from: 'field_0'
    fill_in 'value_0', with: 'Mark Twain'
    click_button 'Perform advanced search'

    expect(page).to have_selector('table.document-list tr td')
    element = find('table.document-list')
    expect(element).to have_content('Fenimore Cooper')
  end
end
