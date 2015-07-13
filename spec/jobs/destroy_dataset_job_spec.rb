require 'spec_helper'

RSpec.describe DestroyDatasetJob, type: :job do
  before(:example) do
    @user = create(:user)
    @dataset = create(:dataset, user: @user)
  end

  context 'when the wrong user is specified' do
    it 'raises an exception and does not destroy a dataset' do
      expect {
        expect {
          described_class.new.perform(create(:user).to_param,
                                       @dataset.to_param)
        }.to raise_error(ActiveRecord::RecordNotFound)
      }.to_not change { @user.datasets.count }
    end
  end

  context 'when an invalid user is specified' do
    it 'raises an exception' do
      expect {
        described_class.new.perform('12345678', @dataset.to_param)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when an invalid dataset is specified' do
    it 'raises an exception and does not destroy a dataset' do
      expect {
        expect {
          described_class.new.perform(@user.to_param, '12345678')
        }.to raise_error(ActiveRecord::RecordNotFound)
      }.to_not change { @user.datasets.count }
    end
  end

  context 'when the parameters are valid' do
    it 'destroys a dataset' do
      expect {
        described_class.new.perform(@user.to_param, @dataset.to_param)
      }.to change { @user.datasets.count }.by(-1)
    end
  end
end
