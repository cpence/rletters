require 'rails_helper'

RSpec.feature 'Using the administration interface', type: :feature do
  scenario 'when viewing the dashboard' do
    sign_in_admin

    # Solr details shown
    expect(page).to have_content('Solr version ')

    # Environment variables shown
    expect(page).to have_selector('td', text: 'APP_NAME')
  end

  scenario 'when viewing a list of objects' do
    # Create some users
    sign_up_with(name: 'First User')
    sign_out
    sign_up_with(name: 'Second User', email: 'wat@wat.com')
    sign_out

    sign_in_admin
    click_link 'Accounts'
    click_link 'Users'

    expect(page).to have_selector('td', text: 'First User')
    expect(page).to have_selector('td', text: 'Second User')

    expect(page).to have_selector("a[href=\"#{admin_item_path(model: 'user', id: User.find_by(name: 'First User').to_param)}\"]")
    expect(page).to have_selector("a[href=\"#{admin_edit_item_path(model: 'user', id: User.find_by(name: 'First User').to_param)}\"]")

    expect(page).to have_selector("a[href=\"#{admin_new_item_path(model: 'user')}\"]")
  end

  scenario 'when viewing the details for a single object' do
    sign_up_with(name: 'First User')
    sign_out

    sign_in_admin
    click_link 'Accounts'
    click_link 'Users'
    # For future reference, this data-original-title is what to look for when
    # you want to click something with tooltip activated
    first('a[data-original-title=Details]').click

    # This selector makes sure we're in the horizontal-table format of the
    # view page and can see data
    expect(page).to have_selector('th + td', text: 'First User')
  end

  scenario 'when editing a single object' do
    sign_up_with(name: 'First User')
    sign_out

    sign_in_admin
    click_link 'Accounts'
    click_link 'Users'
    first('a[data-original-title=Edit]').click

    fill_in 'item_password', with: 'changeme'
    fill_in 'item_password_confirmation', with: 'changeme'
    fill_in 'item_name', with: 'New Name'

    click_button 'Update user'

    expect(page).to have_selector('td', text: 'New Name')
  end

  scenario 'when bulk-editing multiple objects' do
    # Create some users
    sign_up_with(name: 'First User')
    sign_out
    sign_up_with(name: 'Second User', email: 'wat@wat.com')
    sign_out

    sign_in_admin
    click_link 'Accounts'
    click_link 'Users'

    check "item_#{User.find_by(name: 'Second User').to_param}"
    accept_confirm do
      click_link 'Delete Checked'
    end

    expect(page).not_to have_text('Second User')
  end

  scenario 'when deleting a single object' do
    # Create some users
    sign_up_with(name: 'First User')
    sign_out
    sign_up_with(name: 'Second User', email: 'wat@wat.com')
    sign_out

    sign_in_admin
    click_link 'Accounts'
    click_link 'Users'

    accept_confirm do
      first('a[data-original-title=Delete]').click
    end

    expect(page).not_to have_text('First User')
  end
end
