# frozen_string_literal: true
require 'application_system_test_case'

class BrowseTest < ApplicationSystemTestCase
  test 'load the default search page' do
    visit search_path
    assert_selector 'table.document-list tr td'
  end

  test 'search for an article' do
    visit search_path

    fill_in 'q', with: 'test'
    find('#q').send_keys(:enter)

    assert_selector 'table.document-list tr td'
    assert_text(/\d+ articles found/i)
  end
end
