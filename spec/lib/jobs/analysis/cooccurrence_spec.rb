require 'spec_helper'

RSpec.describe Jobs::Analysis::Cooccurrence do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, working: true, user: @user)
    @task = create(:analysis_task, dataset: @dataset)

    # Don't run the analyses
    allow_any_instance_of(RLetters::Analysis::Cooccurrence::Base).to receive(:call) do |analyzer|
      p = analyzer.instance_variable_get(:@progress)
      p && p.call(100)
      [['word other', 1]]
    end
  end

  it_should_behave_like 'an analysis job' do
    let(:job_params) { { word: 'was', window: '6' } }
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
    it 'throws an exception if the type is invalid' do
      expect {
        Jobs::Analysis::Cooccurrence.perform(
          '123',
          user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          task_id: @task.to_param,
          analysis_type: 'nope',
          num_pairs: '10',
          window: 25,
          word: 'disease')
      }.to raise_error(ArgumentError)
    end

    types = [:mi, :t, :likelihood]
    words_list = ['disease', 'tropical, disease']
    nums = [[:num_pairs, '10'], [:all, '1']]

    types.product(words_list).product(nums).each do |((type, words), (sym, val))|
      it "runs with type '#{type}' and words '#{words}'" do
        expect {
          Jobs::Analysis::Cooccurrence.perform(
            '123',
            user_id: @user.to_param,
            dataset_id: @dataset.to_param,
            task_id: @task.to_param,
            analysis_type: type.to_s,
            sym => val,
            window: '25',
            word: words)
        }.not_to raise_error

        # Just a quick sanity check to make sure some code was called
        expect(@dataset.analysis_tasks[0].name).to eq('Determine significant associations between distant pairs of words')
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
