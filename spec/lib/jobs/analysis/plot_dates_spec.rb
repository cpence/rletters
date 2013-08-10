# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::Analysis::PlotDates, vcr: { cassette_name: 'plot_dates' } do

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
  end

  it_should_behave_like 'an analysis job with a file'

  context 'when all parameters are valid' do

    before(:each) do
      Jobs::Analysis::PlotDates.new(user_id: @user.to_param,
                                    dataset_id: @dataset.to_param).perform
    end

    after(:each) do
      @dataset.analysis_tasks[0].destroy
    end

    it 'names the task correctly' do
      expect(@dataset.analysis_tasks[0].name).to eq('Plot dataset by date')
    end

    it 'creates good YAML' do
      arr = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
      expect(arr).to be_an(Array)
    end

    it 'fills in some values' do
      arr = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
      expect((1990..2012)).to cover(arr[0][0])
      expect((1..5)).to cover(arr[0][1])
    end
  end

end
