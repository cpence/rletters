require 'rails_helper'

RSpec.describe CooccurrenceJob, type: :job do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, working: true, user: @user)
    @task = create(:task, dataset: @dataset)
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

        expect(@task.name).to eq('Determine significant associations between distant pairs of words')
        expect(@task.files[0].result.file_contents(:original)).to match(/\n"?\w+,? \w+"?,\d+(\.\d+)?/)
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
