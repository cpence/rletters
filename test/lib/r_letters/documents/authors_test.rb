require 'test_helper'

class RLetters::Documents::AuthorsTest < ActiveSupport::TestCase
  test 'from_list works with a list of names' do
    RLetters::Documents::Author.expects(:new).with(full: 'A One')
    RLetters::Documents::Author.expects(:new).with(full: 'B Two')

    RLetters::Documents::Authors.from_list('A One, B Two')
  end

  test 'from_list returns an empty string on nil' do
    assert_equal [], RLetters::Documents::Authors.from_list(nil)
  end

  test 'from_list returns an empty string on blank' do
    assert_equal [], RLetters::Documents::Authors.from_list('  ')
  end

  test 'to_s works as expected' do
    a = RLetters::Documents::Authors.from_list('A One, B Two')
    assert_equal 'A One, B Two', a.to_s
  end
end
