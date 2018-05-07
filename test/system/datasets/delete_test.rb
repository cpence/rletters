# frozen_string_literal: true

require 'application_system_test_case'

class DeleteTest < ApplicationSystemTestCase
  test 'delete a dataset' do
    sign_in_with
    create_dataset

    visit datasets_path
    assert_selector 'td', text: 'Integration Dataset'

    accept_confirm do
      click_link 'Delete'
    end

    assert_selector 'td', text: 'No datasets'
  end
end
