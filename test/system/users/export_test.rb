# frozen_string_literal: true

require 'application_system_test_case'

class ExportTest < ApplicationSystemTestCase
  test 'exporting user data' do
    sign_in_with

    visit root_path
    within('.navbar') { click_link 'My Account' }

    # Open the modal and approve it
    click_link 'Build export'
    click_link 'Build Export'

    perform_enqueued_jobs

    # Force the page to refresh now that the job was performed
    visit root_path
    within('.navbar') { click_link 'My Account' }

    # Make sure the download button is there
    assert_link 'Download'

    # Delete the file
    click_link 'Delete'

    # Now, the warning that you can't export twice in 24h should be visible
    assert_text 'You can only export your data'
  end
end
