require 'rails_helper'

RSpec.describe RLetters::VirtusExt::DatasetID do
  class DsIdTester
    include Virtus.model(strict: true)
    attribute :dataset, RLetters::VirtusExt::DatasetID, required: true
  end

  describe '#coerce' do
    it 'passes through a Dataset' do
      dataset = build(:full_dataset)
      model = DsIdTester.new(dataset: dataset)

      expect(model.dataset).to eq(dataset)
    end

    it 'resolves a GID' do
      dataset = create(:full_dataset)
      model = DsIdTester.new(dataset: dataset.to_global_id.to_s)

      expect(model.dataset).to eq(dataset)
    end

    it 'looks up an ID' do
      dataset = create(:full_dataset)
      model = DsIdTester.new(dataset: dataset.to_param)

      expect(model.dataset).to eq(dataset)
    end

    it 'raises on a missing ID' do
      expect {
        DsIdTester.new(dataset: '132')
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'chokes on anything else' do
      expect {
        DsIdTester.new(dataset: 37)
      }.to raise_error(ArgumentError)
    end
  end
end
