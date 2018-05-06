# frozen_string_literal: true
require 'test_helper'

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  test 'should not get export as HTML' do
    get documents_export_url(uid: generate(:working_uid))

    assert_response 406
  end

  RLetters::Documents::Serializers::Base.available.each do |k|
    test "should export in #{k} format" do
      get documents_export_url(uid: generate(:working_uid), format: k.to_s)

      assert_valid_download(Mime::Type.lookup_by_extension(k).to_s, @response)
    end
  end

  test 'should not export an invalid format' do
    get documents_export_url(uid: generate(:working_uid), format: 'csv')

    assert_response 406
  end

  test 'should redirect citeulike' do
    stub_connection(/www\.citeulike\.org/, 'citeulike')

    get documents_citeulike_url(uid: 'doi:10.1371/journal.pntd.0000534')

    assert_redirected_to 'http://www.citeulike.org/article/10443922'
  end

  test 'should fail citeulike when not found' do
    stub_connection(/www\.citeulike\.org/, 'citeulike_failure')

    get documents_citeulike_url(uid: 'doi:10.1371/journal.pntd.0000534')

    assert_response 404
  end

  test 'should fail citeulike when timed out' do
    stub_request(:any, %r{www\.citeulike\.org/json/.*}).to_timeout

    get documents_citeulike_url(uid: 'doi:10.1371/journal.pntd.0000534')

    assert_response 404
  end
end
