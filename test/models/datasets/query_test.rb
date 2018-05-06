# frozen_string_literal: true
require 'test_helper'

class Datasets::QueryTest < ActiveSupport::TestCase
  test 'should be invalid without type' do
    query = build_stubbed(:query, def_type: nil)

    refute query.valid?
  end

  test 'should be valid with good type' do
    query = create(:query)

    assert query.valid?
  end
end
