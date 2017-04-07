require 'application_system_test_case'

class SortTest < ApplicationSystemTestCase
  test 'change sort order' do
    visit search_path

    click_link('Sort', match: :first)
    click_link('Sort: Authors (ascending)')

    within 'table.document-list' do
      assert_text 'Why Arboviruses Can Be Neglected'
    end
  end
end
