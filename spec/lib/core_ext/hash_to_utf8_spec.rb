# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Hash do
  describe '#to_utf8!' do
    before(:each) do
      @hash = {
        one: 'asdf'.encode('iso-8859-1'),
        two: [{ three: 'ghjk'.encode('iso-8859-1') }]
      }
    end

    it 'is not UTF-8 at first' do
      expect(@hash[:one].encoding).not_to eq(Encoding::UTF_8)
      expect(@hash[:two][0][:three].encoding).not_to eq(Encoding::UTF_8)
    end

    it 'converts all strings to UTF-8' do
      @hash.to_utf8!

      expect(@hash[:one].encoding).to eq(Encoding::UTF_8)
      expect(@hash[:two][0][:three].encoding).to eq(Encoding::UTF_8)
    end
  end
end
