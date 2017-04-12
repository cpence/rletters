require 'test_helper'

class UnapiControllerTest < ActionDispatch::IntegrationTest
  def get_unapi(with_id = false, format = nil)
    if with_id
      @id = generate(:working_uid)
      get unapi_url(id: @id, format: format)
    else
      get unapi_url
    end

    return if format
    @doc = Nokogiri::XML::Document.parse(response.body)
    @formats = @doc.root.css('format').to_a
  end

  test 'should get format list' do
    get_unapi

    assert_response :success

    # Validate the unAPI response here
    assert_equal 'application/xml', @response.content_type
    assert_equal 'formats', @doc.root.name
    refute_empty @formats

    @formats.each do |f|
      assert_includes f.attributes.keys, 'type'
      assert_includes f.attributes.keys, 'name'
    end
  end

  test 'should get document format list' do
    get_unapi true

    assert_response 300

    assert_equal 'application/xml', @response.content_type
    refute_empty @formats

    @formats.each do |f|
      assert_includes f.attributes.keys, 'type'
      assert_includes f.attributes.keys, 'name'
    end
  end

  test 'should fail with 406 for bad formats' do
    get_unapi true, 'css'

    assert_response 406
  end

  test 'should export for all formats' do
    get_unapi true

    @formats.each do |f|
      get_unapi true, f.attributes['name']

      url = documents_export_url(uid: @id, format: f.attributes['name'].to_s)
      assert_redirected_to url
    end
  end
end
