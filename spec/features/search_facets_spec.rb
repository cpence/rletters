require 'rails_helper'

RSpec.feature 'Searching with facets', type: :feature do
  scenario 'when browsing by journal' do
    visit search_path

    within('.well .nav') do
      click_link 'PLoS Neglected Tropical Diseases'
    end

    expect(page).to have_content(/1500 articles /i)
    expect(page).to have_selector('li', text: 'PLoS Neglected Tropical Diseases')
  end

  scenario 'when clearing a single facet' do
    visit search_path

    within('.well .nav') do
      click_link 'PLoS Neglected Tropical Diseases'
      click_link 'Peter J. Hotez'
    end

    within('#filters') do
      click_link 'Authors: Peter J. Hotez'
    end

    expect(page).to have_content(/1500 articles /i)
    expect(page).to have_selector('li', text: 'PLoS Neglected Tropical Diseases')
  end

  scenario 'when browsing by journal' do
    visit search_path

    within('.well .nav') do
      click_link 'PLoS Neglected Tropical Diseases'
    end
    within('#filters') do
      click_link('Remove All')
    end

    expect(page).to have_content(/1502 articles /i)
    expect(page).not_to have_selector('li', text: 'Active filters')
  end
end
