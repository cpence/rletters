require 'spec_helper'

RSpec.feature 'Search result is sorted', type: :feature do
  scenario 'when changing the order' do
    visit search_path

    click_link('Sort', match: :first)
    click_link('Sort: Authors (ascending)')

    element = find('table.document-list')
    expect(element).to have_content('Why Arboviruses Can Be Neglected')
  end
end
