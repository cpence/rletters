# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe Jobs::Analysis::TermDates do

  it_should_behave_like 'an analysis job'

  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, working: true, user: @user)
    @task = create(:analysis_task, dataset: @dataset)
  end

  describe '.download?' do
    it 'is false' do
      expect(Jobs::Analysis::TermDates.download?).to be false
    end
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(Jobs::Analysis::TermDates.num_datasets).to eq(1)
    end
  end

  before(:example) do
    Jobs::Analysis::TermDates.perform(
      '123',
      user_id: @user.to_param,
      dataset_id: @dataset.to_param,
      task_id: @task.to_param,
      term: 'blackwell')
  end

  it 'names the task correctly' do
    expect(@dataset.analysis_tasks[0].name).to eq('Plot word occurrences by date')
  end

  it 'creates good JSON' do
    data = JSON.load(@dataset.analysis_tasks[0].result.file_contents(:original))
    expect(data).to be_a(Hash)
  end

  it 'fills in some values' do
    arr = JSON.load(@dataset.analysis_tasks[0].result.file_contents(:original))['data']
    expect((1990..2012)).to cover(arr[0][0])
    expect((0..1)).to cover(arr[0][1])
  end

  it 'fills in some zeroes in intervening years' do
    arr = JSON.load(@dataset.analysis_tasks[0].result.file_contents(:original))['data']
    elt = arr.find { |y| y[1] == 0 }
    expect(elt).to be
  end

end
