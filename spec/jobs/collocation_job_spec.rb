require 'rails_helper'

RSpec.describe CollocationJob, type: :job do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, working: true, entries_count: 2,
                                     user: @user)
    @task = create(:task, dataset: @dataset)

    @old_path = ENV['NLP_TOOL_PATH']
    ENV['NLP_TOOL_PATH'] = 'stubbed'

    @words = build(:parts_of_speech)
    allow(RLetters::Analysis::NLP).to receive(:parts_of_speech).and_return(@words)

    # Don't run the analyses
    allow(RLetters::Analysis::Collocation).to receive(:call) do |args|
      p = args['progress']
      p && p.call(100)
      [['word other', 1]]
    end
  end

  after(:example) do
    ENV['NLP_TOOL_PATH'] = @old_path
  end

  it_should_behave_like 'an analysis job' do
    let(:job_params) { { 'scoring' => 't_test' } }
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(described_class.num_datasets).to eq(1)
    end
  end

  describe '.perform' do
    it 'throws an exception if the type is invalid' do
      expect {
        described_class.new.perform(
          @task,
          'scoring' => 'nope',
          'num_pairs' => '10')
      }.to raise_error(ArgumentError)
    end

    it 'falls back to MI if POS is selected but unavailable' do
      ENV['NLP_TOOL_PATH'] = nil

      expect(RLetters::Analysis::Collocation).to receive(:call).with(hash_including('scoring' => 'mutual_information'))
      described_class.new.perform(
        @task,
        'scoring' => 'parts_of_speech',
        'num_pairs' => '10')
    end

    types = [:mutual_information, :t_test, :log_likelihood, :parts_of_speech]
    nums = [[:num_pairs, '10'], [:all, '1']]
    types.product(nums).each do |(type, (sym, val))|
      it "runs with type '#{type}'" do
        expect {
          described_class.new.perform(
            @task,
            'scoring' => type.to_s,
            sym.to_s => val)
        }.not_to raise_error

        # Just a quick sanity check to make sure some code was called
        expect(@dataset.tasks[0].name).to eq('Determine significant associations between immediate pairs of words')
      end
    end
  end

  describe '.significance_tests' do
    it 'gives a reasonable answer' do
      tests = described_class.significance_tests
      expect(tests).to include(['Log-likelihood', :log_likelihood])
    end
  end
end
