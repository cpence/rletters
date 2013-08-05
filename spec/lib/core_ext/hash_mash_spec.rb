# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Hash do

  # This is called sometimes by rsolr-ext
  describe '#to_mash' do
    it 'is callable and returns the right thing' do
      hash = { 'test' => 'test2' }
      hash2 = hash.to_mash

      hash2.class.should eq(HashWithIndifferentAccess)
      hash2[:test].should eq('test2')
    end
  end

end
