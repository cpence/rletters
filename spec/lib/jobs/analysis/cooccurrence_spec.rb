# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe Jobs::Analysis::Cooccurrence do

  it_should_behave_like 'an analysis job' do
    let(:job_params) { { word: 'ethology' } }
  end

  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, entries_count: 10, working: true,
                                     user: @user)
    @task = create(:analysis_task, dataset: @dataset)
  end

  describe '.download?' do
    it 'is true' do
      expect(Jobs::Analysis::Cooccurrence.download?).to be true
    end
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(Jobs::Analysis::Cooccurrence.num_datasets).to eq(1)
    end
  end

  describe '.perform' do
    it 'accepts all the valid parameters' do
      [:mi, :t].each do |p|
        expect {
          Jobs::Analysis::Cooccurrence.perform(
            '123',
            user_id: @user.to_param,
            dataset_id: @dataset.to_param,
            task_id: @task.to_param,
            analysis_type: p.to_s,
            num_pairs: '10',
            window: 25,
            word: 'ethology')
        }.to_not raise_error

        expect(@dataset.analysis_tasks[0].name).to eq('Determine significant associations between distant pairs of words')

        @output = CSV.parse(@dataset.analysis_tasks[0].result.file_contents(:original))
        expect(@output).to be_an(Array)

        words, sig = @output[4]

        expect(words.split.count).to eq(2)
        expect(sig.to_f).to be_finite
      end
    end
  end
end
