require 'rails_helper'

RSpec.describe CollocationJob, type: :job do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, working: true, num_docs: 2, user: @user)
    @task = create(:task, dataset: @dataset)

    @old_path = ENV['NLP_TOOL_PATH']
    ENV['NLP_TOOL_PATH'] = 'stubbed'

    @words = build(:parts_of_speech)
    allow(RLetters::Analysis::NLP).to receive(:parts_of_speech).at_least(:once).and_return(@words)
  end

  after(:example) do
    ENV['NLP_TOOL_PATH'] = @old_path
  end

  it_should_behave_like 'an analysis job' do
    let(:job_params) { { 'scoring' => 'mutual_information' } }
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(described_class.num_datasets).to eq(1)
    end
  end

  describe '.perform' do
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

        # There should be at least one collocation in there ("word word,X.YYYY...")
        expect(@task.name).to eq('Determine significant associations between immediate pairs of words')
        expect(@task.files.first.result.file_contents(:original)).to match(/\n"?\w+,? \w+"?,\d+(\.\d+)?/)
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
