require 'rails_helper'

RSpec.describe RLetters::Presenters::TaskPresenter do
  context 'with JSON available' do
    before(:example) do
      @task = create(:task, job_type: 'ExportCitationsJob')
      @task.files.create!(description: 'test',
                          short_description: 'test') do |f|
        f.from_string('{"abc":123}', filename: 'test.json',
                                     content_type: 'application/json')
      end
      @task.reload

      @presenter = described_class.new(task: @task)
    end

    describe '#json_escaped' do
      it 'escapes the JSON' do
        expect(@presenter.json_escaped).to eq('{\"abc\":123}')
      end
    end
  end

  context 'with no JSON available' do
    before(:example) do
      @task = create(:task, job_type: 'ExportCitationsJob')
      @presenter = described_class.new(task: @task)
    end

    describe '#json_escaped' do
      it 'is nil' do
        expect(@presenter.json_escaped).to be_nil
      end
    end
  end

  describe '#status_message' do
    it 'works with both percent and message' do
      task = double('Datasets::Task', progress: 0.3, progress_message: 'Going')
      presenter = described_class.new(task: task)

      expect(presenter.status_message).to eq('30%: Going')
    end

    it 'works with only percent' do
      task = double('Datasets::Task', progress: 0.3, progress_message: nil)
      presenter = described_class.new(task: task)

      expect(presenter.status_message).to eq('30%')
    end

    it 'works with only message' do
      task = double('Datasets::Task', progress: nil, progress_message: 'Going')
      presenter = described_class.new(task: task)

      expect(presenter.status_message).to eq('Going')
    end
  end
end
