require 'spec_helper'

RSpec.feature 'User runs workflow on existing datasets', type: :feature do
  scenario 'when linking one dataset' do
    sign_in_with
    create_dataset

    visit root_path
    click_link 'Start a new analysis'
    click_link 'When were a given set of articles published?'
    click_link 'Start'

    click_link 'Link an already created dataset'
    within('.modal-dialog') do
      click_button 'Link dataset'
    end

    click_link 'Set Job Options'
    click_button 'Start analysis job'

    within('.navbar') { click_link 'Fetch' }
    expect(page).to have_selector('td', text: 'Integration Dataset')
    expect(page).to have_selector('td', text: 'Plot number of articles by date')

    click_link 'View'
    expect(page).to have_link('Download in CSV format')
  end

  scenario 'when linking two datasets' do
    sign_in_with
    create_dataset
    create_dataset(name: 'Other Dataset')

    visit root_path
    click_link 'Start a new analysis'
    click_link 'Given two sets of articles, what words mark out an article'
    click_link 'Start'

    click_link 'Link an already created dataset'
    within('.modal-dialog') do
      select 'Integration Dataset', from: 'link_dataset_id'
      click_button 'Link dataset'
    end

    click_link 'Link an already created dataset'
    within('.modal-dialog') do
      select 'Other Dataset', from: 'link_dataset_id'
      click_button 'Link dataset'
    end

    find('a.btn-success', text: 'Start Analysis').click

    within('.navbar') { click_link 'Fetch' }
    expect(page).to have_selector('td', text: 'Integration Dataset')

    click_link 'View'
    expect(page).to have_link('Download in CSV format')
  end
end
