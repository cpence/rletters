require 'spec_helper'

# A mock job for testing the base code
class MockJob < BaseJob
  def call_standard_options(user_id, dataset_id, task_id)
    standard_options(user_id, dataset_id, task_id)
  end
end

RSpec.describe BaseJob, type: :job do
  describe '.t' do
    it 'queries the right keys' do
      expect(I18n).to receive(:t).with('mock_job.testing', {})
      MockJob.t('.testing')
    end
  end

  describe '.add_concern' do
    before(:context) do
      # Only do this once; doing it twice raises a NameError
      MockJob.add_concern 'NormalizeDocumentCounts'
    end

    it 'adds to the view path' do
      expected = Rails.root.join('lib', 'jobs', 'analysis', 'concerns',
                                 'views', 'normalize_document_counts')
      expect(MockJob.view_paths).to include(expected)
    end

    it 'throws an error if you try to repeat it' do
      expect {
        MockJob.add_concern 'NormalizeDocumentCounts'
      }.to raise_error(ArgumentError)
    end
  end

  describe '.view?' do
    it 'returns correct values' do
      expect(ArticleDatesJob.view?('_params')).to be true
      expect(CraigZetaJob.view?('_params')).to be false
    end
  end

  describe '.view_paths' do
    it 'returns the base path' do
      expected = Rails.root.join('lib', 'jobs', 'analysis', 'views', 'mock')
      expect(MockJob.view_paths).to include(expected)
    end
  end

  describe '.view_path' do
    context 'with neither template nor partial' do
      it 'raises an error' do
        expect {
          MockJob.view_path(bad: true)
        }.to raise_error(ArgumentError)
      end
    end

    context 'with template' do
      it 'returns nil for missing views' do
        expect(MockJob.view_path(template: 'test')).to be_nil
      end

      it 'returns path for available views' do
        expected = Rails.root.join('lib', 'jobs', 'analysis', 'views',
                                   'named_entities', 'results.html.haml').to_s
        expect(NamedEntitiesJob.view_path(template: 'results')).to eq(expected)
      end
    end

    context 'with partial' do
      it 'returns nil for missing views' do
        expect(MockJob.view_path(partial: 'what')).to be_nil
      end

      it 'returns path for available views' do
        expected = Rails.root.join('lib', 'jobs', 'analysis', 'views',
                                   'article_dates', '_params.html.haml').to_s
        expect(ArticleDatesJob.view_path(partial: 'params')).to eq(expected)
      end

      it 'returns path for concern views' do
        expected = Rails.root.join('lib', 'jobs', 'analysis', 'concerns',
                                   'views', 'normalize_document_counts',
                                   '_normalize_document_counts.html.haml').to_s
        expect(ArticleDatesJob.view_path(partial: 'normalize_document_counts')).to eq(expected)
      end
    end
  end

  describe '.job_list' do
    before(:example) do
      @jobs = described_class.job_list
    end

    it 'returns a non-empty array' do
      expect(@jobs).not_to be_empty
    end

    it 'contains a class we know exists' do
      expect(@jobs).to include(ExportCitationsJob)
    end
  end

  describe '#standard_options!' do
    before(:example) do
      @user = create(:user)
      @dataset = create(:full_dataset, user: @user)
      @task = create(:task, dataset: @dataset)
    end

    context 'with the wrong user' do
      it 'raises an exception' do
        expect {
          MockJob.new.call_standard_options(create(:user).to_param,
                                            @dataset.to_param, @task.to_param)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with an invalid user' do
      it 'raises an exception' do
        expect {
          MockJob.new.call_standard_options('123456', @dataset.to_param,
                                            @task.to_param)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with an invalid dataset' do
      it 'raises an exception' do
        expect {
          MockJob.new.call_standard_options(@user.to_param, '123456',
                                            @task.to_param)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with an invalid task' do
      it 'raises an exception' do
        expect {
          MockJob.new.call_standard_options(@user.to_param, @dataset.to_param,
                                            '123456')
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '.available?' do
    it 'is true by default' do
      expect(MockJob.available?).to be true
    end
  end
end
