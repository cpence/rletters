# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Hash do

  describe '#without_indifferent_access' do
    context 'with hashes as hash keys' do
      it 'converts successfully' do
        hash = { 'test' => { 'test2' => 'test3' }.with_indifferent_access }.with_indifferent_access
        hash2 = hash.without_indifferent_access

        expect(hash2[:test]).to eq(nil)
        expect(hash2['test'][:test2]).to eq(nil)
        expect(hash2['test']['test2']).to eq('test3')
      end
    end

    context 'without hashes as hash keys' do
      it 'converts successfully' do
        hash = { 'test' => 'test2' }.with_indifferent_access
        hash2 = hash.without_indifferent_access

        expect(hash2[:test]).to eq(nil)
        expect(hash2['test']).to eq('test2')
      end
    end
  end

end

describe Array do

  describe '#without_indifferent_access' do
    context 'with no hashes' do
      it 'leaves the array alone' do
        arr = [1, 3, 5]
        arr2 = arr.without_indifferent_access

        expect(arr2).to eq(arr)
      end
    end

    context 'with non-indifferent hashes' do
      it 'leaves the hashes alone' do
        arr = [1, 3, { 'test' => 'test2' }]
        arr2 = arr.without_indifferent_access

        expect(arr2[2]).to eq({ 'test' => 'test2' })
        expect(arr2[2].class).to eq(Hash)
      end
    end

    context 'with indifferent hashes' do
      it 'converts them to regular Hashes' do
        arr = [1, 3, { 'test' => 'test2' }.with_indifferent_access]
        arr2 = arr.without_indifferent_access

        expect(arr2[2]).to eq({ 'test' => 'test2' })
        expect(arr2[2][:test]).to eq(nil)
        expect(arr2[2].class).to eq(Hash)
      end
    end
  end

end
