require 'minitest/assertions'

module Minitest::Assertions
  def assert_valid_download(mime, response)
    assert response.successful?
    assert response.content_type = mime
    assert response.body.length != 0
  end
end
