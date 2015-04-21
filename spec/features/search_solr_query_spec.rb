require 'spec_helper'

RSpec.feature 'Searching with a Solr query', type: :feature do
  scenario 'when running an author search' do
    visit '/search/advanced'
    click_link 'Search with Solr syntax'
    fill_in 'q', with: 'authors:"Hotez" OR journal:"Gutenberg"'
    click_button 'Perform Solr query'

    expect(page).to have_selector('table.document-list tr td')
    expect(page).to have_content(/52 articles /i)
  end
end
