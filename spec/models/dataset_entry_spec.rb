# -*- encoding : utf-8 -*-
require 'spec_helper'

describe DatasetEntry do

  describe '#valid?' do
    context 'when no shasum is specified' do
      before(:each) do
        @entry = FactoryGirl.build(:dataset_entry, shasum: nil)
      end

      it 'is not valid' do
        expect(@entry).not_to be_valid
      end
    end

    context 'when a short shasum is specified' do
      before(:each) do
        @entry = FactoryGirl.build(:dataset_entry, shasum: 'notanshasum')
      end

      it 'is not valid' do
        expect(@entry).not_to be_valid
      end
    end

    context 'when an invalid shasum is specified' do
      before(:each) do
        @entry = FactoryGirl.build(:dataset_entry, shasum: '1234567890thisisbad!')
      end

      it 'is not valid' do
        expect(@entry).not_to be_valid
      end
    end

    context 'when a good shasum is specified' do
      before(:each) do
        @entry = FactoryGirl.create(:dataset_entry)
      end

      it 'is valid' do
        expect(@entry).to be_valid
      end
    end
  end

end
