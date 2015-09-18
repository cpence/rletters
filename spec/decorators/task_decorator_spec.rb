require 'rails_helper'

RSpec.describe TaskDecorator, type: :decorator do
  context 'with JSON available' do
    before(:each) do
      @task = create(:task, job_type: 'ExportCitationsJob')

      ios = StringIO.new('{"abc":123}')
      file = Paperclip.io_adapters.for(ios)
      file.original_filename = 'test.json'
      file.content_type = 'application/json'

      @task.files.create!(description: 'test', short_description: 'test',
                          result: file)
      @task.reload
      @decorated = described_class.decorate(@task)
    end

    describe '#json' do
      it 'returns the JSON' do
        expect(@decorated.json).to eq('{"abc":123}')
      end
    end

    describe '#json_escaped' do
      it 'escapes the JSON' do
        expect(@decorated.json_escaped).to eq('{\"abc\":123}')
      end
    end
  end

  context 'with no JSON available' do
    before(:each) do
      @task = create(:task, job_type: 'ExportCitationsJob')
      @decorated = described_class.decorate(@task)
    end

    describe '#json' do
      it 'is nil' do
        expect(@decorated.json).to be_nil
      end
    end

    describe '#json_escaped' do
      it 'is nil' do
        expect(@decorated.json_escaped).to be_nil
      end
    end
  end

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
