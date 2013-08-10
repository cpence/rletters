# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Array do

  describe '#with_indifferent_access' do
    context 'with an array without hashes' do
      it 'does not convert anything' do
        arr = [1, 2, 3, 4]
        arr2 = arr.with_indifferent_access

        expect(arr).to eq(arr2)
      end
    end

    context 'with an array with hashes' do
      it 'converts the hashes' do
        arr = [1, 3, { 'test' => 'test2' }, [2, 4, 6, { 'test3' => 'test4' }]]
        arr2 = arr.with_indifferent_access

        expect(arr2[2][:test]).to eq('test2')
        expect(arr2[3][3][:test3]).to eq('test4')
      end
    end
  end

end

describe Object do

  describe '#with_indifferent_access' do
    context 'when self is not duplicable' do
      it 'calls successfully but does not change anything' do
        expect(1.with_indifferent_access).to eq(1)
      end
    end

    context 'when self is duplicable' do
      it 'calls successfully but does not change anything' do
        expect('asdf'.with_indifferent_access).to eq('asdf')
      end
    end
  end

end
