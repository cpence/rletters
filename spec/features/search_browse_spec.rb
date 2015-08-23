require 'rails_helper'

RSpec.feature 'Searching to browse the database', type: :feature do
  scenario 'when loading the default page' do
    visit search_path
    expect(page).to have_selector('table.document-list tr td')
  end

  scenario 'when searching for an article' do
    visit search_path

    fill_in 'q', with: 'test'
    page.execute_script("$('form').submit();")

    expect(page).to have_selector('table.document-list tr td')
    expect(page).to have_content(/\d+ articles found/i)
  end
end
