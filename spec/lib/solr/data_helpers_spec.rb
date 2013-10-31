# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Solr::DataHelpers do

  describe '.count_by_field' do
    context 'without a dataset' do
      before(:each) do
        @counts = Solr::DataHelpers.count_by_field(nil, :year)
      end

      it 'gets the values for the whole corpus' do
        expect(@counts['2009']).to eq(104)
        expect(@counts['2000']).to eq(31)
      end
    end

    context 'with a dataset' do
      before(:each) do
        @user = FactoryGirl.create(:user)
        @dataset = FactoryGirl.create(:full_dataset, working: true, user: @user)
        @counts = Solr::DataHelpers.count_by_field(@dataset, :year)
      end

      it 'gets the values for the dataset' do
        @counts.each do |k, v|
          expect((1990..2012)).to cover(Integer(k))
          expect((1..10)).to cover(v)
        end
      end
    end
  end

end
