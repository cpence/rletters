# frozen_string_literal: true
require 'test_helper'

class RLetters::VirtusExt::DatasetIDTest < ActiveSupport::TestCase
  class DsIdTester
    include Virtus.model(strict: true)
    attribute :dataset, RLetters::VirtusExt::DatasetID, required: true
  end

  test 'coerce passes through a dataset' do
    dataset = build(:full_dataset)
    model = DsIdTester.new(dataset: dataset)

    assert_equal dataset, model.dataset
  end

  test 'coerce resolves a GID' do
    dataset = create(:full_dataset)
    model = DsIdTester.new(dataset: dataset.to_global_id.to_s)

    assert_equal dataset, model.dataset
  end

  test 'coerce looks up an ID' do
    dataset = create(:full_dataset)
    model = DsIdTester.new(dataset: dataset.to_param)

    assert_equal dataset, model.dataset
  end

  test 'coerce raises if ID missing' do
    assert_raises(ActiveRecord::RecordNotFound) do
      DsIdTester.new(dataset: '12345')
    end
  end

  test 'coerce chokes on anything else' do
    assert_raises(ArgumentError) do
      DsIdTester.new(dataset: 37)
    end
  end
end
