# frozen_string_literal: true

module RLetters::Documents::Serializers::CommonTests
  def test_class_methods_work
    assert_kind_of String, RLetters::Documents::Serializers::RIS.format
    assert_kind_of String, RLetters::Documents::Serializers::RIS.url
  end
end
