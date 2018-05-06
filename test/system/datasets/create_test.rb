# frozen_string_literal: true
require 'application_system_test_case'

class CreateTest < ApplicationSystemTestCase
  test 'create a dataset' do
    sign_in_with
    create_dataset

    visit datasets_path
    assert_selector 'td', text: 'Integration Dataset'

    click_link 'Manage'
    assert_text 'Information for dataset — Integration Dataset'
  end
end
