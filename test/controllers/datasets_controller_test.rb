require 'test_helper'

class DatasetsControllerTest < ActionDispatch::IntegrationTest
  test 'should redirect index when not logged in' do
    get datasets_url

    assert_redirected_to root_url
  end

  test 'should get index' do
    sign_in create(:user)

    get datasets_url

    assert_response :success
  end

  test 'should get index via XHR' do
    sign_in create(:user)

    get datasets_url, xhr: true

    assert_response :success
  end

  test 'should get new' do
    sign_in create(:user)

    get new_dataset_url

    assert_response :success
  end

  test 'should create with no workflow active' do
    user = create(:user)
    sign_in user

    post datasets_url(dataset: { name: 'New Dataset' },
                      q: '*:*',
                      def_type: 'lucene')

    assert_equal 1, user.datasets.reload.size

    d = user.datasets.first
    assert_equal 'New Dataset', d.name
    assert_equal 1, d.queries.size
    assert_equal '*:*', d.queries[0].q
    assert_equal 'lucene', d.queries[0].def_type

    assert_redirected_to datasets_path
  end

  test 'should create with an active workflow' do
    user = create(:user)
    user.workflow_active = true
    user.workflow_class = 'ArticleDatesJob'
    user.save!
    sign_in user

    post datasets_url(dataset: { name: 'New Dataset' },
                      q: '*:*',
                      def_type: 'lucene')

    assert_redirected_to workflow_activate_path('ArticleDatesJob')
    refute_nil flash[:success]

    assert_equal 1, user.reload.workflow_datasets.count
    assert_equal user.datasets.reload.first.to_param, user.workflow_datasets[0]
  end

  test 'should get show without clear_failed' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    get dataset_url(id: dataset.to_param)

    assert_response :success
  end

  test 'should get show with clear_failed' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    create(:task, dataset: dataset, failed: true)
    sign_in user

    get dataset_url(id: dataset.to_param, clear_failed: true)

    assert_response :success
    assert_empty dataset.reload.tasks.failed
    refute_nil flash[:notice]
  end

  test 'should delete dataset' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    delete dataset_url(id: dataset.to_param)

    assert_redirected_to datasets_url
    assert_empty user.datasets.reload
  end

  test 'should fail to update with an invalid document' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    patch dataset_url(id: dataset.to_param, uid: 'fail')

    assert_response 404
  end

  test 'should patch update' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    assert_difference('dataset.reload.document_count', 1) do
      patch dataset_url(id: dataset.to_param, uid: generate(:working_uid))
    end

    assert_redirected_to dataset_url(dataset)
  end

  test 'should patch update with a remote document' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    refute dataset.fetch

    patch dataset_url(id: dataset.to_param, uid: 'gutenberg:3172')

    assert dataset.reload.fetch
  end
end
