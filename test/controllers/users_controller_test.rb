require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test 'cannot create export if not signed in' do
    get user_export_path

    assert_redirected_to(root_path)
  end

  test 'cannot create export if user did so too recently' do
    user = create(:user, export_requested_at: 2.hours.ago)
    sign_in user

    get user_export_path

    assert_response 500
  end

  test 'creating export enqueues job' do
    user = create(:user)
    sign_in user

    assert_enqueued_jobs 0, only: UserExportJob

    get user_export_path

    assert_enqueued_jobs 1, only: UserExportJob
  end

  test 'creating export updates request time' do
    old_at = 5.days.ago
    user = create(:user, export_requested_at: old_at)
    sign_in user

    get user_export_path

    assert_not_equal user.export_requested_at, old_at
  end

  test 'cannot delete export if not signed in' do
    delete user_export_path

    assert_redirected_to(root_path)
  end

  test 'cannot delete export if no export attached' do
    user = create(:user)
    sign_in user

    delete user_export_path

    assert_response 404
  end

  test 'deleting export enqueues job' do
    user = create(:user)
    user.export_archive = ActiveStorage::Blob.create_after_upload!(
      io: StringIO.new('this is not really a zip file'),
      filename: 'export.zip', content_type: 'application/zip')
    sign_in user

    assert_enqueued_jobs 0, only: ActiveStorage::PurgeJob

    delete user_export_path

    assert_enqueued_jobs 1, only: ActiveStorage::PurgeJob
  end
end
