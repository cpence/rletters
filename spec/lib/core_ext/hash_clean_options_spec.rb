# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Hash do
  describe '#clean_options!' do
    before(:each) do
      @hash = {
        nil_key: nil,
        blank_key: '',
        whitespace_key: '   ',
        good_key: 'asdf',
        'string_key' => '  asdf  '
      }
      @hash.clean_options!
    end

    it 'removes nils' do
      expect(@hash).not_to include(:nil_key)
    end

    it 'removes blanks' do
      expect(@hash).not_to include(:blank_key)
    end

    it 'removes whitespace' do
      expect(@hash).not_to include(:whitespace_key)
    end

    it 'leaves non-ws strings alone' do
      expect(@hash[:good_key]).to eq('asdf')
    end

    it 'symbolizes keys' do
      expect(@hash).to include(:string_key)
    end

    it 'strips whitespace on values' do
      expect(@hash[:string_key]).to eq('asdf')
    end
  end
end
