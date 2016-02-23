require 'rails_helper'

RSpec.feature 'User aborts the workflow construction', type: :feature do
  scenario 'when a workflow is partially built' do
    sign_in_with
    create_dataset

    visit root_path
    click_link 'Start a new analysis'
    click_link 'When were a given set of articles published?'
    first(:link, 'Start', exact: true).click

    click_link 'Link an already created dataset'
    within('.modal-dialog') do
      click_button 'Link dataset'
    end

    click_link 'Abort Building Analysis'

    visit root_path
    expect(page).not_to have_link('Current Analysis')
  end
end
