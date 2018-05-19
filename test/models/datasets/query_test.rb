# frozen_string_literal: true

require 'test_helper'

module Datasets
  class QueryTest < ActiveSupport::TestCase
    test 'should be invalid without type' do
      query = build_stubbed(:query, def_type: nil)

      refute query.valid?
    end

    test 'should be valid with good type' do
      query = create(:query)

      assert query.valid?
    end

    test 'to_s should work' do
      query = build(:query)

      assert_includes query.to_s, query.def_type
    end
  end
end
