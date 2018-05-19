# frozen_string_literal: true

require 'test_helper'

module RLetters
  module Solr
    class AdvancedTest < ActiveSupport::TestCase
      test 'search_fields works' do
        ret = RLetters::Solr::Advanced.search_fields

        assert_kind_of Hash, ret
        assert_kind_of String, ret.keys[0]
        assert_kind_of Symbol, ret.values[0]
        assert_includes ret.values, :pages
      end
    end
  end
end
