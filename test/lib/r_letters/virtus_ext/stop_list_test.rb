require 'test_helper'

class StopListTest < ActiveSupport::TestCase
  class StopTester
    include Virtus.model(strict: true)
    attribute :list, RLetters::VirtusExt::StopList, required: true
  end

  test 'coerce passes through a Documents::StopList' do
    stop_list = build(:stop_list)
    model = StopTester.new(list: stop_list)

    assert_equal %w(a an the), model.list.sort
  end

  test 'coerce loads the list if there is one' do
    create(:stop_list)
    model = StopTester.new(list: 'en')

    assert_equal %w(a an the), model.list.sort
  end

  test 'coerce loads a string to a space-separated list without match' do
    model = StopTester.new(list: 'a an the')

    assert_equal %w(a an the), model.list.sort
  end

  test 'coerce chokes on anything else' do
    assert_raises(ArgumentError) do
      StopTester.new(list: 38)
    end
  end
end
