# frozen_string_literal: true
require 'application_system_test_case'

class AddDocumentTest < ApplicationSystemTestCase
  test 'add a single article' do
    sign_in_with
    create_dataset

    visit datasets_path
    assert_selector 'td', text: 'Integration Dataset'
    click_link 'Manage'

    assert_text 'Number of documents: 427'

    visit search_path
    first(:button, 'More').click
    click_link 'Add this document to an existing dataset'

    within('.modal-dialog') do
      click_button 'Add'
    end

    visit datasets_path
    assert_selector 'td', text: 'Integration Dataset'
    click_link 'Manage'

    assert_text 'Number of documents: 428'
  end
end
