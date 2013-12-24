# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::Analysis::WordFrequency do

  it_should_behave_like 'an analysis job'

  before(:each) do
    @user = FactoryGirl.create(:user)
    @dataset = FactoryGirl.create(:full_dataset, entries_count: 10,
                                                 working: true, user: @user)
    @task = FactoryGirl.create(:analysis_task, dataset: @dataset)
  end

  describe '.download?' do
    it 'is true' do
      expect(Jobs::Analysis::WordFrequency.download?).to be true
    end
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(Jobs::Analysis::WordFrequency.num_datasets).to eq(1)
    end
  end

  describe '#perform' do
    it 'accepts all the various valid parameters' do
      params_to_test =
        [{ user_id: @user.to_param,
           dataset_id: @dataset.to_param,
           task_id: @task.to_param,
           block_size: '100',
           split_across: '1',
           num_words: '0' },
         { user_id: @user.to_param,
           dataset_id: @dataset.to_param,
           task_id: @task.to_param,
           block_size: '100',
           split_across: '0',
           num_words: '0' },
         { user_id: @user.to_param,
           dataset_id: @dataset.to_param,
           task_id: @task.to_param,
           num_blocks: '10',
           split_across: '1',
           num_words: '0' },
         { user_id: @user.to_param,
           dataset_id: @dataset.to_param,
           task_id: @task.to_param,
           num_blocks: '10',
           split_across: '1',
           num_words: '0',
           inclusion_list: 'asdf,sdfhj,wert' },
         { user_id: @user.to_param,
           dataset_id: @dataset.to_param,
           task_id: @task.to_param,
           num_blocks: '10',
           split_across: '1',
           num_words: '0',
           exclusion_list: 'asdf,sdfgh,qwert' },
         { user_id: @user.to_param,
           dataset_id: @dataset.to_param,
           task_id: @task.to_param,
           num_blocks: '10',
           split_across: '1',
           num_words: '0',
           stop_list: 'en' }]

      expect {
        params_to_test.each do |params|
          Jobs::Analysis::WordFrequency.perform('123', params)
        end
      }.to_not raise_error
    end

    context 'when all parameters are valid' do
      before(:each) do
        Jobs::Analysis::WordFrequency.perform(
          '123',
          user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          task_id: @task.to_param,
          block_size: '100',
          split_across: 'true',
          num_words: '0')

        @output = CSV.parse(@dataset.analysis_tasks[0].result.file_contents(:original))
      end

      it 'names the task correctly' do
        expect(@dataset.analysis_tasks[0].name).to eq('Analyze word frequency in dataset')
      end

      it 'creates good CSV' do
        expect(@output).to be_an(Array)
      end
    end
  end
end
