# frozen_string_literal: true

require 'application_system_test_case'

class ExistingDataTest < ApplicationSystemTestCase
  test 'workflow with one existing dataset' do
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

    click_link 'Set Job Options'

    click_button 'Start analysis job'
    perform_enqueued_jobs

    within('.navbar') { click_link 'Fetch' }
    assert_selector 'td', text: 'Integration Dataset'
    assert_selector 'td', text: 'Plot number of articles by date'

    click_link 'View'
    assert has_link?('Download in CSV format')
  end

  test 'workflow with two existing datasets' do
    sign_in_with
    create_dataset(q: 'green')
    create_dataset(name: 'Other Dataset', q: 'blue')

    # This analysis takes ~60sec, which is an intolerable test delay
    stub_craig_zeta!

    visit root_path
    click_link 'Start a new analysis'
    click_link 'Given two sets of articles, what words mark out an article'
    first(:link, 'Start', exact: true).click

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

    click_link 'Start Analysis', class: 'btn'
    perform_enqueued_jobs

    within('.navbar') { click_link 'Fetch' }
    assert_selector 'td', text: 'Integration Dataset'

    click_link 'View'
    assert has_link?('Download in CSV format')
  end
end
