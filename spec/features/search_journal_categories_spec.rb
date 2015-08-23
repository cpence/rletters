require 'rails_helper'

RSpec.feature 'Searching with journal categories', type: :feature do
  before(:each) do
    root = Documents::Category.create(
      name: 'Root',
      journals: ['PLoS Neglected Tropical Diseases', 'Gutenberg'])
    root.children.create(name: 'PNTD',
                         journals: ['PLoS Neglected Tropical Diseases'])
    root.children.create(name: 'Gutenberg', journals: ['Gutenberg'])
  end

  scenario 'when adding a category' do
    visit search_path

    within('.well .nav') do
      click_link('PNTD')
    end

    expect(page).to have_content(/1500 articles /i)
    expect(page).to have_selector('.main .navbar .navbar-btn', text: /Category: PNTD/)
  end

  scenario 'clearing a category' do
    visit search_path

    within('.well .nav') do
      click_link('PNTD')
      click_link('Gutenberg')
    end

    within('.well .nav') do
      click_link('Gutenberg')
    end

    expect(page).to have_content(/1500 articles /i)
    expect(page).to have_selector('.main .navbar .navbar-btn', text: /Category: PNTD/)
  end

  scenario 'clearing all categories' do
    visit search_path

    within('.well .nav') do
      click_link('Gutenberg')
    end

    within('.main .navbar') do
      click_link('Remove All')
    end

    expect(page).to have_content(/1502 articles /i)
    expect(page).to have_selector('.main .navbar .navbar-btn', text: 'No filters active')
  end
end
