require 'test_helper'
require 'core_ext/hash/deep_transform_values'

class HashDeepTransformValuesTest < ActiveSupport::TestCase
  test 'deep_transform_values returns a new hash' do
    original = { a: 'a', b: 'b' }
    mapped = original.deep_transform_values(&:upcase)

    assert_equal({ a: 'a', b: 'b' }, original)
    assert_equal({ a: 'A', b: 'B' }, mapped)
  end

  test 'deep_transform_values finds nested hashes' do
    original = { a: 'a', b: { c: 'c' }, d: [{ e: 'f' }] }
    mapped = original.deep_transform_values(&:upcase)

    assert_equal({ a: 'A', b: { c: 'C' }, d: [{ e: 'F' }] }, mapped)
  end

  test 'deep_transform_values! modifies keys of the original' do
    original = { a: 'a', b: 'b' }
    mapped = original.deep_transform_values!(&:upcase)

    assert_equal({ a: 'A', b: 'B' }, original)
    assert_same original, mapped
  end

  test 'deep_transform_values! finds nested hashes' do
    original = { a: 'a', b: { c: 'c' }, d: [{ e: 'f' }] }
    original.deep_transform_values!(&:upcase)

    assert_equal({ a: 'A', b: { c: 'C' }, d: [{ e: 'F' }] }, original)
  end
end
