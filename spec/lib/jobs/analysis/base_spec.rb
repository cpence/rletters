require 'spec_helper'

module Jobs
  module Analysis
    # A mock job for testing the base code
    class MockJob < Jobs::Analysis::Base
      def call_standard_options
        standard_options!
      end

      attr_accessor :options
    end
  end
end

RSpec.describe Jobs::Analysis::Base do
  describe '.t' do
    it 'queries the right keys' do
      expect(I18n).to receive(:t).with('jobs.analysis.mock_job.testing', {})
      Jobs::Analysis::MockJob.t('.testing')
    end
  end

  describe '.add_concern' do
    before(:context) do
      # Only do this once; doing it twice raises a NameError
      Jobs::Analysis::MockJob.add_concern 'NormalizeDocumentCounts'
    end

    it 'adds to the view path' do
      expected = Rails.root.join('lib', 'jobs', 'analysis', 'concerns',
                                 'views', 'normalize_document_counts')
      expect(Jobs::Analysis::MockJob.view_paths).to include(expected)
    end

    it 'throws an error if you try to repeat it' do
      expect {
        Jobs::Analysis::MockJob.add_concern 'NormalizeDocumentCounts'
      }.to raise_error(ArgumentError)
    end
  end

  describe '.view?' do
    it 'returns correct values' do
      expect(Jobs::Analysis::ArticleDates.view?('_params')).to be true
      expect(Jobs::Analysis::CraigZeta.view?('_params')).to be false
    end
  end

  describe '.view_paths' do
    it 'returns the base path' do
      expected = Rails.root.join('lib', 'jobs', 'analysis',
                                 'views', 'mock_job')
      expect(Jobs::Analysis::MockJob.view_paths).to include(expected)
    end
  end

  describe '.view_path' do
    context 'with neither template nor partial' do
      it 'raises an error' do
        expect {
          Jobs::Analysis::MockJob.view_path(bad: true)
        }.to raise_error(ArgumentError)
      end
    end

    context 'with template' do
      it 'returns nil for missing views' do
        expect(Jobs::Analysis::MockJob.view_path(template: 'test')).to be_nil
      end

      it 'returns path for available views' do
        expected = Rails.root.join('lib', 'jobs', 'analysis', 'views',
                                   'named_entities', 'results.html.haml').to_s
        expect(Jobs::Analysis::NamedEntities.view_path(template: 'results')).to eq(expected)
      end
    end

    context 'with partial' do
      it 'returns nil for missing views' do
        expect(Jobs::Analysis::MockJob.view_path(partial: 'what')).to be_nil
      end

      it 'returns path for available views' do
        expected = Rails.root.join('lib', 'jobs', 'analysis', 'views',
                                   'article_dates', '_params.html.haml').to_s
        expect(Jobs::Analysis::ArticleDates.view_path(partial: 'params')).to eq(expected)
      end

      it 'returns path for concern views' do
        expected = Rails.root.join('lib', 'jobs', 'analysis', 'concerns',
                                   'views', 'normalize_document_counts',
                                   '_normalize_document_counts.html.haml').to_s
        expect(Jobs::Analysis::ArticleDates.view_path(partial: 'normalize_document_counts')).to eq(expected)
      end
    end
  end

  describe '.job_list' do
    before(:example) do
      @jobs = Jobs::Analysis::Base.job_list
    end

    it 'returns a non-empty array' do
      expect(@jobs).not_to be_empty
    end

    it 'contains a class we know exists' do
      expect(@jobs).to include(Jobs::Analysis::ExportCitations)
    end
  end

  describe '#standard_options!' do
    before(:example) do
      @user = create(:user)
      @dataset = create(:full_dataset, user: @user)
      @task = create(:task, dataset: @dataset)

      @job = Jobs::Analysis::MockJob.new(
        'asdf',
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        task_id: @task.to_param
      )
    end

    context 'with the wrong user' do
      it 'raises an exception' do
        @job.options[:user_id] = create(:user).to_param
        expect { @job.call_standard_options }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with an invalid user' do
      it 'raises an exception' do
        @job.options[:user_id] = '123456'
        expect { @job.call_standard_options }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with an invalid dataset' do
      it 'raises an exception' do
        @job.options[:dataset_id] = '12345678'
        expect { @job.call_standard_options }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with an invalid task' do
      it 'raises an exception' do
        @job.options[:task_id] = '12345678'
        expect { @job.call_standard_options }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '.queue' do
    it 'is set' do
      expect(Jobs::Analysis::MockJob.queue).to eq(:analysis)
    end
  end

  describe '.available?' do
    it 'is true by default' do
      expect(Jobs::Analysis::MockJob.available?).to be true
    end
  end

  it 'includes the resque-status methods' do
    expect(Jobs::Analysis::MockJob.methods).to include(:create)
  end
end
