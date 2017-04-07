require 'application_system_test_case'

class AdminTest < ApplicationSystemTestCase
  test 'view the dashboard' do
    sign_in_admin

    assert_text 'Solr version '
    assert_selector 'td', text: 'APP_NAME'
  end

  test 'view a list of objects' do
    # Create some users
    sign_up_with(name: 'First User')
    sign_out
    sign_up_with(name: 'Second User', email: 'wat@wat.com')
    sign_out

    sign_in_admin
    click_link 'Accounts'
    click_link 'Users'

    assert_selector 'td', text: 'First User'
    assert_selector 'td', text: 'Second User'

    assert_selector "a[href=\"#{admin_item_path(model: 'user', id: User.find_by(name: 'First User').to_param)}\"]"
    assert_selector "a[href=\"#{admin_edit_item_path(model: 'user', id: User.find_by(name: 'First User').to_param)}\"]"

    assert_selector "a[href=\"#{admin_new_item_path(model: 'user')}\"]"
  end

  test 'view details for a single object' do
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
    assert_selector 'th + td', text: 'First User'
  end

  test 'edit a single object' do
    sign_up_with(name: 'First User')
    sign_out

    sign_in_admin
    click_link 'Accounts'
    click_link 'Users'
    first('a[data-original-title=Edit]').click

    fill_in 'item_password', with: 'changeme'
    fill_in 'item_password_confirmation', with: 'changeme'
    fill_in 'item_name', with: 'New Name'

    click_button 'Update User'

    assert_selector 'td', text: 'New Name'
  end

  test 'bulk-edit multiple objects' do
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

    assert_no_text 'Second User'
  end

  test 'delete a single object' do
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

    assert_no_text 'First User'
  end
end
