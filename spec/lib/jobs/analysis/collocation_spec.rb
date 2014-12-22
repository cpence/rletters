# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe Jobs::Analysis::Collocation do

  it_should_behave_like 'an analysis job'

  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, working: true, entries_count: 2,
                      user: @user)
    @task = create(:analysis_task, dataset: @dataset)

    @old_path = Admin::Setting.nlp_tool_path
    Admin::Setting.nlp_tool_path = 'stubbed'

    @words = build(:parts_of_speech)
    allow(RLetters::Analysis::NLP).to receive(:parts_of_speech).and_return(@words)

    # Don't run the analyses
    allow_any_instance_of(RLetters::Analysis::Collocation::LogLikelihood).to receive(:call) do |analyzer|
      p = analyzer.instance_variable_get(:@progress)
      p && p.call(100)
      [['word other', 1]]
    end
    allow_any_instance_of(RLetters::Analysis::Collocation::TTest).to receive(:call) do |analyzer|
      p = analyzer.instance_variable_get(:@progress)
      p && p.call(100)
      [['word other', 1]]
    end
    allow_any_instance_of(RLetters::Analysis::Collocation::MutualInformation).to receive(:call) do |analyzer|
      p = analyzer.instance_variable_get(:@progress)
      p && p.call(100)
      [['word other', 1]]
    end
    allow_any_instance_of(RLetters::Analysis::Collocation::PartsOfSpeech).to receive(:call) do |analyzer|
      p = analyzer.instance_variable_get(:@progress)
      p && p.call(100)
      [['word other', 1]]
    end
  end

  after(:example) do
    Admin::Setting.nlp_tool_path = @old_path
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
    it 'throws an exception if the type is invalid' do
      expect {
        Jobs::Analysis::Collocation.perform(
          '123',
          user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          task_id: @task.to_param,
          analysis_type: 'nope',
          num_pairs: '10')
      }.to raise_error(ArgumentError)
    end

    it 'falls back to MI if POS is selected but unavailable' do
      Admin::Setting.nlp_tool_path = nil

      expect(RLetters::Analysis::Collocation::MutualInformation).to receive(:new).and_call_original
      expect(RLetters::Analysis::Collocation::PartsOfSpeech).not_to receive(:new)

      Jobs::Analysis::Collocation.perform(
        '123',
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        task_id: @task.to_param,
        analysis_type: 'pos',
        num_pairs: '10')
    end

    valid_params = [:mi, :t, :likelihood, :pos]

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

        # Just a quick sanity check to make sure some code was called
        expect(@dataset.analysis_tasks[0].name).to eq('Determine significant associations between immediate pairs of words')
      end
    end
  end

  describe '.significance_tests' do
    it 'gives a reasonable answer' do
      tests = described_class.significance_tests
      expect(tests).to include(['Log-likelihood', :likelihood])
    end
  end
end
