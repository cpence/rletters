require 'application_system_test_case'

class AdvancedTest < ApplicationSystemTestCase
  test 'search for an author' do
    visit '/search/advanced'
    select 'Authors', from: 'field_0'
    fill_in 'value_0', with: 'Mark Twain'
    click_button 'Perform advanced search'

    assert_selector 'table.document-list tr td'
    within 'table.document-list:first-of-type' do
      assert_text 'Fenimore Cooper'
    end
  end
end
