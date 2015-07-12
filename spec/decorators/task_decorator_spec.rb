require 'spec_helper'

RSpec.describe TaskDecorator, type: :decorator do
  describe '#status_message' do
    it 'works with both percent and message' do
      task = double('Datasets::Task', progress: 0.3, progress_message: 'Going')
      decorated = described_class.decorate(task)

      expect(decorated.status_message).to eq('30%: Going')
    end

    it 'works with only percent' do
      task = double('Datasets::Task', progress: 0.3, progress_message: nil)
      decorated = described_class.decorate(task)

      expect(decorated.status_message).to eq('30%')
    end

    it 'works with only message' do
      task = double('Datasets::Task', progress: nil, progress_message: 'Going')
      decorated = described_class.decorate(task)

      expect(decorated.status_message).to eq('Going')
    end
  end
end
