require 'rails_helper'

RSpec.feature 'Using the administration interface', type: :feature do
  scenario 'when viewing the dashboard' do
    sign_in_admin

    # Solr details shown
    expect(page).to have_content('Solr version ')

    # Environment variables shown
    expect(page).to have_selector('td', text: 'APP_NAME')
  end

  scenario 'when viewing a list of objects'

  scenario 'when viewing the details for a single object'

  scenario 'when editing a single object'

  scenario 'when bulk-editing multiple objects'

  scenario 'when deleting a single object'
end
