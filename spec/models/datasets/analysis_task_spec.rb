# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Datasets::AnalysisTask do

  describe '#valid?' do
    context 'when no name is specified' do
      before(:each) do
        @task = build(:analysis_task, name: nil)
      end

      it 'is not valid' do
        expect(@task).not_to be_valid
      end
    end

    context 'when no dataset is specified' do
      before(:each) do
        @task = build(:analysis_task, dataset: nil)
      end

      it 'is not valid' do
        expect(@task).not_to be_valid
      end
    end

    context 'when no type is specified' do
      before(:each) do
        @task = build(:analysis_task, job_type: nil)
      end

      it 'is not valid' do
        expect(@task).not_to be_valid
      end
    end

    context 'when dataset, type, and name are specified' do
      before(:each) do
        @task = create(:analysis_task)
      end

      it 'is valid' do
        expect(@task).to be_valid
      end
    end
  end

  describe '#finished_at' do
    context 'when newly created' do
      before(:each) do
        @task = create(:analysis_task)
      end

      it 'is not set' do
        expect(@task.finished_at).to be_nil
      end
    end
  end

  describe '#failed' do
    context 'when newly created' do
      before(:each) do
        @task = create(:analysis_task)
      end

      it 'is false' do
        expect(@task.finished_at).to be_nil
      end
    end
  end

  def create_task_with_file
    @task = create(:analysis_task)

    ios = StringIO.new('test')
    file = Paperclip.io_adapters.for(ios)
    file.original_filename = 'test.txt'
    file.content_type = 'text/plain'

    @task.result = file
    @task.save
  end

  describe '#result_file' do
    context 'when a file is created' do
      before(:each) do
        create_task_with_file
      end

      after(:each) do
        @task.destroy
      end

      it 'has the right file length' do
        expect(@task.result_file_size).to eq(4)
      end

      it 'has the right contents' do
        expect(@task.result.file_contents(:original)).to eq('test')
      end

      it 'has the right mime type' do
        expect(@task.result_content_type.to_s).to eq('text/plain')
      end
    end
  end

  describe '.job_class' do
    context 'with a good class' do
      it 'returns the class' do
        klass = Datasets::AnalysisTask.job_class('ExportCitations')
        expect(klass).to eq(Jobs::Analysis::ExportCitations)
      end
    end

    context 'with a bad class' do
      it 'raises an error' do
        expect {
          Datasets::AnalysisTask.job_class('NotClass')
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#job_class' do
    context 'with a good job_type' do
      it 'returns the class' do
        task = create(:analysis_task, job_type: 'ExportCitations')
        klass = task.job_class
        expect(klass).to eq(Jobs::Analysis::ExportCitations)
      end
    end

    context 'with a bad class' do
      it 'raises an error' do
        task = create(:analysis_task)
        expect {
          task.job_class
        }.to raise_error(ArgumentError)
      end
    end
  end

end
