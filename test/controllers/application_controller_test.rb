# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test 'devise should redirect to root after login' do
    user = create(:user)
    get root_url
    post user_session_url, params: { user: { email: user.email, password: user.password } }

    assert_redirected_to root_url
  end

  test 'devise should redirect to root after logout' do
    user = create(:user)
    sign_in user

    get destroy_user_session_url

    assert_redirected_to root_url
  end

  test 'should render full_page layout for Devise pages' do
    user = create(:user)
    sign_in user

    get edit_user_registration_url

    assert_template layout: 'layouts/full_page'
  end

  test 'should render application layout for other pages' do
    get search_url

    assert_template layout: 'layouts/application'
  end

  test 'should leave set_locale at default with no user' do
    get workflow_url

    assert_equal I18n.default_locale, I18n.locale
  end

  test 'should have set_locale return user locale when logged in' do
    user = create(:user, language: 'es-MX')
    sign_in user

    get workflow_url

    assert_equal :'es-MX', I18n.locale

    # Sometimes this doesn't get reset, if we get tests in a strange random
    # order.
    I18n.locale = :en
  end

  test 'should leave set_timezone at default with no user' do
    get workflow_url

    assert_equal 'Eastern Time (US & Canada)', Time.zone.name
  end

  test 'should have set_timezone return user timezone when logged in' do
    user = create(:user, timezone: 'Mexico City')
    sign_in user

    get workflow_url

    assert_equal 'Mexico City', Time.zone.name
  end

  test 'should return localized error path when possible' do
    user = create(:user, language: 'es')
    sign_in user

    path = Rails.root.join('public', '555.es.html')
    FileUtils.touch(path)

    get workflow_url
    assert_equal path, controller.send(:error_page_path, '555')

    FileUtils.rm(path)
    I18n.locale = :en
  end

  test 'should return error path' do
    path = Rails.root.join('public', '404.html')

    get workflow_url
    assert_equal path, controller.send(:error_page_path)
  end
end
