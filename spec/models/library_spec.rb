# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Library do

  describe '#valid?' do
    context 'when no name spcified' do
      before(:each) do
        @library = FactoryGirl.build(:library, name: nil)
      end

      it 'is not valid' do
        expect(@library).not_to be_valid
      end
    end

    context 'when no user specified' do
      before(:each) do
        @library = FactoryGirl.build(:library, user: nil)
      end

      it 'is not valid' do
        expect(@library).not_to be_valid
      end
    end

    context 'when no URL specified' do
      before(:each) do
        @library = FactoryGirl.build(:library, url: nil)
      end

      it 'is not valid' do
        expect(@library).not_to be_valid
      end
    end

    context 'with a complete URL' do
      before(:each) do
        @library = FactoryGirl.create(:library, url: 'http://google.com/wut?')
      end

      it 'is valid' do
        expect(@library).to be_valid
      end
    end
  end

  describe 'URL parsing' do
    context 'when given a URL without protocol' do
      before(:each) do
        @library = FactoryGirl.create(:library, url: 'google.com/wut?')
      end

      it 'is valid' do
        expect(@library).to be_valid
      end

      it 'adds the protocol' do
        @library.valid?
        expect(@library.url).to eq('http://google.com/wut?')
      end
    end

    context 'when given a URL with no trailing question mark' do
      before(:each) do
        @library = FactoryGirl.create(:library, url: 'http://google.com')
      end

      it 'is valid' do
        expect(@library).to be_valid
      end

      it 'adds the question mark' do
        @library.valid?
        expect(@library.url).to eq('http://google.com?')
      end
    end

    context 'when given a URL with a bad protocol' do
      before(:each) do
        @library = FactoryGirl.build(:library, url: 'file:///usr/share/pwned')
      end

      it 'is not valid' do
        expect(@library).not_to be_valid
      end
    end
  end

end

