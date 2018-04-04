require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    sign_in create(:administrator)

    get admin_url

    assert_response :success
  end

  test 'should get collection index' do
    sign_in create(:administrator)
    create(:user)
    create(:user)

    get admin_collection_url(model: 'user')

    assert_response :success
  end

  test 'should get tree collection index' do
    sign_in create(:administrator)
    root = create(:category)
    create(:category, parent_id: root.id)

    get admin_collection_url(model: 'documents/category')

    assert_response :success
  end

  test 'should patch collection bulk delete' do
    sign_in create(:administrator)
    users = [create(:user), create(:user), create(:user)]

    patch admin_edit_collection_url(model: 'user',
                                    bulk_action: 'delete',
                                    ids: [users[0].id, users[2].id].to_json)

    refute User.exists?(users[0].id)
    assert User.exists?(users[1].id)
    refute User.exists?(users[2].id)
  end

  test 'should patch collection tree edit' do
    sign_in create(:administrator)
    root = create(:category)
    child = create(:category, parent_id: root.id)

    # Swap the parent and child
    new_tree = [{'id' => child.to_param,
                 'children' => [{'id' => root.to_param}]}]

    patch admin_edit_collection_url(model: 'documents/category',
                                    bulk_action: 'tree',
                                    tree: new_tree.to_json)

    root.reload
    child.reload

    assert_equal 1, Documents::Category.roots.size
    assert_equal child.id, Documents::Category.roots[0].id
    assert_equal 1, child.children.size
    assert_equal root.id, child.children[0].id
  end

  test 'should fail to patch with bad action' do
    sign_in create(:administrator)

    patch admin_edit_collection_url(model: 'user', bulk_action: 'what')

    assert_response 422
  end

  test 'should get single item' do
    sign_in create(:administrator)
    user = create(:user)

    get admin_item_url(model: 'user', id: user.to_param)

    assert_response :success
  end

  test 'should get new item form' do
    sign_in create(:administrator)

    get admin_new_item_url(model: 'user')

    assert_response :success
  end

  test 'should create new item' do
    sign_in create(:administrator)
    attributes = attributes_for(:user)

    post admin_collection_url(model: 'user', item: attributes)

    refute_nil User.find_by(name: attributes[:name])
  end

  test 'should delete item' do
    sign_in create(:administrator)
    user = create(:user)

    assert_difference('User.count', -1) do
      delete admin_item_url(model: 'user', id: user.to_param)
    end
  end

  test 'should get edit form' do
    sign_in create(:administrator)
    user = create(:user)

    get admin_edit_item_url(model: 'user', id: user.to_param)

    assert_response :success
  end

  test 'should patch item edit' do
    sign_in create(:administrator)
    user = create(:user)

    patch admin_item_url(model: 'user', id: user.to_param,
                         item: { email: 'wat@wat.com' })

    assert_equal 'wat@wat.com', user.reload.email
  end

  test 'should redirect index if not logged in' do
    get admin_url

    assert_redirected_to new_administrator_session_url
  end

  test 'should redirect collection if not logged in' do
    get admin_collection_url(model: 'user')

    assert_redirected_to new_administrator_session_url
  end

  test 'should redirect edit collection if not logged in' do
    user = create(:user)

    patch admin_edit_collection_url(model: 'user',
                                    batch_action: 'delete',
                                    ids: "[#{user.to_param}]")

    assert_redirected_to new_administrator_session_url
    assert User.exists?(user.id)
  end

  test 'should redirect item if not logged in' do
    user = create(:user)

    get admin_item_url(model: 'user', id: user.to_param)

    assert_redirected_to new_administrator_session_url
  end

  test 'should redirect new item if not logged in' do
    get admin_new_item_url(model: 'user')

    assert_redirected_to new_administrator_session_url
  end

  test 'should redirect create item if not logged in' do
    assert_no_difference('User.count') do
      post admin_collection_url(model: 'user', item: attributes_for(:user))
    end

    assert_redirected_to new_administrator_session_url
  end

  test 'should redirect delete item if not logged in' do
    user = create(:user)

    assert_no_difference('User.count') do
      delete admin_item_url(model: 'user', id: user.to_param)
    end

    assert_redirected_to new_administrator_session_url
  end

  test 'should redirect edit item form if not logged in' do
    user = create(:user)

    get admin_edit_item_url(model: 'user', id: user.to_param)

    assert_redirected_to new_administrator_session_url
  end

  test 'should redirect edit item if not logged in' do
    user = create(:user)

    patch admin_item_url(model: 'user', id: user.to_param,
                         item: { email: 'wat@wat.com' })

    assert_redirected_to new_administrator_session_url
    refute_equal 'wat@wat.com', user.email
  end
end
