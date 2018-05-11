# frozen_string_literal: true

require 'application_system_test_case'

class AdvancedTest < ApplicationSystemTestCase
  test 'search for an author' do
    visit '/search/advanced'
    select 'Authors', from: 'field_0'
    fill_in 'value_0', with: 'Charles Dickens'
    click_button 'Perform advanced search'

    assert_selector 'table.document-list tr td'
    element = find('table.document-list:first-of-type', match: :first)
    element.assert_text 'Actually a Novel'
  end
end
