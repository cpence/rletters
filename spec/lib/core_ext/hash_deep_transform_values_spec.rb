require 'spec_helper'
require 'core_ext/hash/deep_transform_values'

RSpec.describe Hash do
  describe '#deep_transform_values' do
    it 'returns a new hash with the values computed from the block' do
      original = { a: 'a', b: 'b' }
      mapped = original.deep_transform_values(&:upcase)

      expect(original).to eq(a: 'a', b: 'b')
      expect(mapped).to eq(a: 'A', b: 'B')
    end

    it 'finds nested hashes' do
      original = { a: 'a', b: { c: 'c' }, d: [{ e: 'f' }] }
      mapped = original.deep_transform_values(&:upcase)

      expect(mapped).to eq(a: 'A', b: { c: 'C' }, d: [{ e: 'F' }])
    end
  end

  describe '#deep_transform_values!' do
    it 'modifies keys of the original' do
      original = { a: 'a', b: 'b' }
      mapped = original.deep_transform_values!(&:upcase)

      expect(original).to eq(a: 'A', b: 'B')
      expect(original).to be(mapped)
    end

    it 'finds nested hashes' do
      original = { a: 'a', b: { c: 'c' }, d: [{ e: 'f' }] }
      original.deep_transform_values!(&:upcase)

      expect(original).to eq(a: 'A', b: { c: 'C' }, d: [{ e: 'F' }])
    end
  end
end
