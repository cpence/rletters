require 'test_helper'

class Datasets::FileTest < ActiveSupport::TestCase
  test 'should be invalid without description' do
    file = build_stubbed(:file, description: nil)

    refute file.valid?
  end

  test 'should be valid with description' do
    file = create(:file)

    assert file.valid?
  end
end
