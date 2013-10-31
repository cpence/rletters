# -*- encoding : utf-8 -*-
require 'spec_helper'

describe DatasetEntry do

  describe '#valid?' do
    context 'when no uid is specified' do
      before(:each) do
        @entry = FactoryGirl.build(:dataset_entry, uid: nil)
      end

      it 'is not valid' do
        expect(@entry).not_to be_valid
      end
    end

    context 'when a good uid is specified' do
      before(:each) do
        @entry = FactoryGirl.create(:dataset_entry)
      end

      it 'is valid' do
        expect(@entry).to be_valid
      end
    end
  end

end
