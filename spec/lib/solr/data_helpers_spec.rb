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
        @dataset = FactoryGirl.create(:dataset, user: @user)
        %w(00040b66948f49c3a6c6c0977530e2014899abf9
           001954306c066a8a4cff3da02f7e9dda8e0fb634
           00496e7961871ad05013e1388aaa6650507b2638
           008896a5c58241b65088d931e02f3bea02fc3bf0
           00972c5123877961056b21aea4177d0dc69c7318
           0097c3434054c25e1ace6243a1ac54b71f35bc28
           0097e0f4029fef57b8158970112ab32c1e692cff
           00a004096479b9332b153e91053f09df8003ef74
           00cdb0f945c1e1d7b7789cd8178f3232a57fee34
           00dbffbfff2d18a74ed5f8895fa9f515bf38bf5f).each do |shasum|
          FactoryGirl.create(:dataset_entry, dataset: @dataset, shasum: shasum)
        end
        @counts = Solr::DataHelpers.count_by_field(@dataset, :year)
      end

      it 'gets the values for the dataset' do
        expect(@counts['2003']).to eq(1)
        expect(@counts['2008']).to eq(2)
      end
    end
  end

end
