require 'spec_helper'

RSpec.describe DestroyDatasetJob, type: :job do
  before(:example) do
    @dataset = create(:dataset)
  end

  context 'when the parameters are valid' do
    it 'destroys a dataset' do
      expect {
        described_class.new.perform(@dataset)
      }.to change { @dataset.user.datasets.count }.by(-1)
    end
  end
end
