# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe Jobs::Analysis::Collocation do

  it_should_behave_like 'an analysis job'

  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, stub: true, english: true, user: @user)
    @task = create(:analysis_task, dataset: @dataset)
  end

  describe '.download?' do
    it 'is true' do
      expect(Jobs::Analysis::Collocation.download?).to be true
    end
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(Jobs::Analysis::Collocation.num_datasets).to eq(1)
    end
  end

  describe '.perform' do
    valid_params = [:mi, :t, :likelihood]
    valid_params << :pos if Admin::Setting.nlp_tool_path.present?

    valid_params.each do |p|
      it "runs with analysis_type '#{p}'" do
        expect {
          Jobs::Analysis::Collocation.perform(
            '123',
            user_id: @user.to_param,
            dataset_id: @dataset.to_param,
            task_id: @task.to_param,
            analysis_type: p.to_s,
            num_pairs: '10')
        }.to_not raise_error

        expect(@dataset.analysis_tasks[0].name).to eq('Determine significant associations between immediate pairs of words')

        @output = CSV.parse(@dataset.analysis_tasks[0].result.file_contents(:original))
        expect(@output).to be_an(Array)

        words, sig = @output[4]

        expect(words.split.count).to eq(2)
        expect(sig.to_f).to be_finite
      end
    end
  end
end
