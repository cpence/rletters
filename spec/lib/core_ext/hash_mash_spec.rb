# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Hash do

  # This is called sometimes by rsolr-ext
  describe '#to_mash' do
    it 'is callable and returns the right thing' do
      hash = { 'test' => 'test2' }
      hash2 = hash.to_mash

      expect(hash2.class).to eq(HashWithIndifferentAccess)
      expect(hash2[:test]).to eq('test2')
    end
  end

end
