require 'application_system_test_case'

class AdminTest < ApplicationSystemTestCase
  test 'view the dashboard' do
    sign_in_admin

    assert_text 'Solr version '
    assert_selector 'td', text: 'APP_NAME'
  end
end
