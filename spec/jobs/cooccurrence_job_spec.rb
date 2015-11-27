require 'rails_helper'

RSpec.describe CooccurrenceJob, type: :job do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, working: true, user: @user)
    @task = create(:task, dataset: @dataset)

    # Don't run the analyses
    allow(RLetters::Analysis::Cooccurrence).to receive(:call) do |args|
      p = args['progress']
      p && p.call(100)
      RLetters::Analysis::Cooccurrence::Result.new(
        scoring: args[:scoring].to_sym,
        stemming: (args[:stemming] && args[:stemming].to_sym) || nil,
        cooccurrences: [['word other', 1]])
    end
  end

  it_should_behave_like 'an analysis job' do
    let(:job_params) {
      { 'scoring' => 't_test', 'words' => 'was', 'window' => '6' }
    }
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(described_class.num_datasets).to eq(1)
    end
  end

  describe '.perform' do
    types = [:mutual_information, :t_test, :log_likelihood]
    words_list = ['disease', 'tropical, disease']
    nums = [[:num_pairs, '10'], [:all, '1']]

    types.product(words_list).product(nums).each do |((type, words), (sym, val))|
      it "runs with type '#{type}' and words '#{words}'" do
        expect {
          described_class.new.perform(
            @task,
            'scoring' => type.to_s,
            sym.to_s => val,
            'window' => '25',
            'words' => words)
        }.not_to raise_error

        # Just a quick sanity check to make sure some code was called
        expect(@dataset.tasks[0].name).to eq('Determine significant associations between distant pairs of words')
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
