# frozen_string_literal: true

require 'test_helper'

class Users::LibrariesControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    user = create(:user)
    library = create(:library, user: user)
    sign_in user

    get libraries_url

    assert_response :success
  end

  test 'should get new form' do
    sign_in create(:user)

    get new_library_url

    assert_response :success
  end

  test 'should create library' do
    sign_in create(:user)

    assert_difference('User.first.libraries.count', 1) do
      post libraries_url(users_library: attributes_for(:library,
                                                       user: User.first))
    end

    assert_redirected_to(edit_user_registration_url)
  end

  test 'should not create invalid library' do
    sign_in create(:user)

    assert_no_difference('User.first.libraries.count') do
      post libraries_url(users_library: attributes_for(:library,
                                                       user: User.first,
                                                       url: 'foo.bar?q=Spaces should be encoded'))
    end

    # Not a redirect; rendering the new form again
    assert_response :success
  end

  test 'should get edit' do
    user = create(:user)
    library = create(:library, user: user)
    sign_in user

    get edit_library_url(id: library.to_param)

    assert_response :success
  end

  test 'should patch update' do
    user = create(:user)
    library = create(:library, user: user)
    sign_in user

    patch library_url(id: library.to_param, users_library: { name: 'Woo' })

    assert_redirected_to(edit_user_registration_url)
    assert_equal 'Woo', library.reload.name
  end

  test 'should not patch update when invalid' do
    user = create(:user)
    library = create(:library, user: user)
    sign_in user

    patch library_url(id: library.to_param,
                      users_library: { url: 'foo.bar?q=Spaces should be encoded' })

    assert_response :success
    refute_equal 'foo.bar?q=Spaces should be encoded', library.reload.url
  end

  test 'should delete library' do
    user = create(:user)
    library = create(:library, user: user)
    sign_in user

    assert_difference('User.first.libraries.count', -1) do
      delete library_url(id: library.to_param)
    end

    assert_redirected_to edit_user_registration_url
  end

  test 'should get query with no libraries' do
    sign_in create(:user)
    stub_connection(/worldcat.org/, 'worldcat_no_libraries')

    get query_libraries_url

    assert_response :success
  end

  test 'should get query with libraries' do
    sign_in create(:user)
    stub_connection(/worldcat.org/, 'worldcat_notre_dame')

    get query_libraries_url

    assert_response :success
  end

  test 'should get query when WorldCat times out' do
    sign_in create(:user)
    stub_request(:any, %r{worldcat.org/registry/lookup.*}).to_timeout

    get query_libraries_url

    assert_response :success
  end
end
