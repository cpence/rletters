# frozen_string_literal: true
require 'test_helper'

class RLetters::VirtusExt::ParameterHashTest < ActiveSupport::TestCase
  class ParamHashTester
    include Virtus.model(strict: true)
    include RLetters::VirtusExt::ParameterHash

    attribute :string, String
  end

  test 'parameter_hash saves base values' do
    model = ParamHashTester.new(string: 'test')

    assert_equal 'test', model.string
    assert_equal 'test', model.parameter_hash[:string]
  end

  test 'parameter_hash saves uncoerced values' do
    model = ParamHashTester.new(string: 37)

    assert_equal '37', model.string
    assert_equal 37, model.parameter_hash[:string]
  end

  test 'parameter_hash saves unused parameters' do
    model = ParamHashTester.new(string: 'test', other: 37)

    assert_equal 37, model.parameter_hash[:other]
  end
end
