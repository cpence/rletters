require 'rails_helper'

RSpec.feature 'Searching with journal categories', type: :feature do
  before(:example) do
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
    expect(page).to have_selector('li', text: /Category: PNTD/)
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
    expect(page).to have_selector('li', text: /Category: PNTD/)
  end

  scenario 'clearing all categories' do
    visit search_path

    within('.well .nav') do
      click_link('Gutenberg')
    end

    within('#filters') do
      click_link('Remove All')
    end

    expect(page).to have_content(/1502 articles /i)
    expect(page).not_to have_selector('li', text: 'Active filters')
  end
end
