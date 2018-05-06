# frozen_string_literal: true
require 'test_helper'

class RLetters::Documents::AuthorTest < ActiveSupport::TestCase
  # Correctly deal with splitting by boolean operators and removing parentheses,
  # when needed
  def query_to_array(str)
    return [str[1..-2]] unless str[0] == '('
    str[1..-2].split(' OR ').map { |n| n[1..-2] }
  end

  test 'full should ignore complex values' do
    au = RLetters::Documents::Author.new(full: 'for the Leishmaniasis East Africa Platform (LEAP) group')
    assert_equal 'for the Leishmaniasis East Africa Platform (LEAP) group', au.full
  end

  test 'full should return the parameter string without parsing' do
    au = RLetters::Documents::Author.new(full: 'Greebleflotz, Johannes van der 123 Jr.')
    assert_equal 'Greebleflotz, Johannes van der 123 Jr.', au.full
  end

  test 'to_s should be the same as full' do
    au = RLetters::Documents::Author.new(full: 'Greebleflotz, Johannes van der 123 Jr.')
    assert_equal au.full, au.to_s
  end

  test 'first should return nothing with only one name' do
    au = RLetters::Documents::Author.new(full: 'Asdf')
    assert_nil au.first
  end

  test 'first returns the first bit, with no comma' do
    au = RLetters::Documents::Author.new(full: 'Asdf Sdfg')
    assert_equal 'Asdf', au.first
  end

  test 'first returns the last bit, with comma' do
    au = RLetters::Documents::Author.new(full: 'Sdfg, Asdf')
    assert_equal 'Asdf', au.first
  end

  test 'last returns the name with one name' do
    au = RLetters::Documents::Author.new(full: 'Asdf')
    assert_equal 'Asdf', au.last
  end

  test 'last returns the last bit, with no comma' do
    au = RLetters::Documents::Author.new(full: 'Asdf Sdfg')
    assert_equal 'Sdfg', au.last
  end

  test 'last returns the first bit, with comma' do
    au = RLetters::Documents::Author.new(full: 'Sdfg, Asdf')
    assert_equal 'Sdfg', au.last
  end

  test 'prefix returns as expected with no comma' do
    au = RLetters::Documents::Author.new(full: 'Asdf van der Sdfg')
    assert_equal 'van der', au.prefix
  end

  test 'prefix returns as expected with comma' do
    au = RLetters::Documents::Author.new(full: 'Van der Sdfg, Asdf')
    assert_equal 'Van der', au.prefix
  end

  test 'suffix returns as expected with comma' do
    # N.B.: the BibTeX::Names parser does not pull out suffixes without comma
    au = RLetters::Documents::Author.new(full: 'van der Sdfg, Jr., Asdf')
    assert_equal 'Jr.', au.suffix
  end

  test 'to_lucene works for Last' do
    expected = ['Last']
    actual = query_to_array(RLetters::Documents::Author.new(full: 'Last').to_lucene)

    assert_equal expected.sort, actual.sort
  end

  test 'to_lucene works for F Last' do
    expected = ['F* Last']
    actual = query_to_array(RLetters::Documents::Author.new(full: 'F Last').to_lucene)

    assert_equal expected.sort, actual.sort
  end

  test 'to_lucene works for FMM Last' do
    expected = ['F* Last', 'F* M* M* Last']
    actual = query_to_array(RLetters::Documents::Author.new(full: 'FMM Last').to_lucene)

    assert_equal expected.sort, actual.sort
  end

  test 'to_lucene works for First Last' do
    expected = ['F Last', 'First Last']
    actual = query_to_array(RLetters::Documents::Author.new(full: 'First Last').to_lucene)

    assert_equal expected.sort, actual.sort
  end

  test 'to_lucene works for First M M Last' do
    expected = ['F M* M* Last', 'First M* M* Last', 'First Last', 'F Last']
    actual = query_to_array(RLetters::Documents::Author.new(full: 'First M M Last').to_lucene)

    assert_equal expected.sort, actual.sort
  end

  test 'to_lucene works for First MM Last' do
    expected = ['F M* M* Last', 'First M* M* Last', 'First Last',
                'F Last']
    actual = query_to_array(RLetters::Documents::Author.new(full: 'First MM Last').to_lucene)

    assert_equal expected.sort, actual.sort
  end

  test 'to_lucene works for First Middle Middle Last' do
    expected = ['First Last', 'F Last', 'First Middle Middle Last',
                'First Middle M Last', 'First M Middle Last',
                'First M M Last', 'First MM Last', 'F Middle Middle Last',
                'F Middle M Last', 'F M Middle Last', 'FM Middle Last',
                'F M M Last', 'FMM Last', 'FM M Last', 'F MM Last']
    actual = query_to_array(RLetters::Documents::Author.new(full: 'First Middle Middle Last').to_lucene)

    assert_equal expected.sort, actual.sort
  end
end
