require 'spec_helper'

RSpec.feature 'Searching with facets', type: :feature do
  scenario 'when browsing by journal' do
    visit search_path

    within('.well .nav') do
      click_link 'PLoS Neglected Tropical Diseases'
    end

    expect(page).to have_content(/1500 articles /i)
    expect(page).to have_selector('.main .navbar .navbar-btn', text: 'PLoS Neglected Tropical Diseases')
  end

  scenario 'when clearing a single facet' do
    visit search_path

    within('.well .nav') do
      click_link 'PLoS Neglected Tropical Diseases'
      click_link 'Peter J. Hotez'
    end

    within('.main .navbar') do
      click_link 'Authors: Peter J. Hotez'
    end

    expect(page).to have_content(/1500 articles /i)
    expect(page).to have_selector('.main .navbar .navbar-btn', text: 'PLoS Neglected Tropical Diseases')
  end

  scenario 'when browsing by journal' do
    visit search_path

    within('.well .nav') do
      click_link 'PLoS Neglected Tropical Diseases'
    end
    within('.main .navbar') do
      click_link('Remove All')
    end

    expect(page).to have_content(/1502 articles /i)
    expect(page).to have_selector('.main .navbar .navbar-btn', text: 'No filters active')
  end
end
