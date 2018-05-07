# frozen_string_literal: true

require 'application_system_test_case'

class AdminTest < ApplicationSystemTestCase
  test 'view the dashboard' do
    # Fake the presence of a job worker, just so we have some data to show
    create :worker_stat

    sign_in_admin

    assert_text 'test worker'
    assert_text 'Solr version '
    assert_selector 'td', text: 'APP_NAME'
  end
end
