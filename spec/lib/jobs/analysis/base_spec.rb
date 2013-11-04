# -*- encoding : utf-8 -*-
require 'spec_helper'

module Jobs
  module Analysis
    class MockJob < Jobs::Analysis::Base
    end
  end
end

describe Jobs::Analysis::Base do

  describe '.t' do
    it 'queries the right keys' do
      expect(I18n).to receive(:t).with('jobs.analysis.mock_job.testing')
      Jobs::Analysis::MockJob.t('.testing')
    end
  end

  describe '.add_concern' do
    before(:all) do
      # Only do this once; doing it twice raises a NameError
      Jobs::Analysis::MockJob.add_concern 'NormalizeDocumentCounts'
    end

    it 'adds to the view path' do
      expected = Rails.root.join('lib', 'jobs', 'analysis', 'concerns', 'views', 'normalize_document_counts')
      expect(Jobs::Analysis::MockJob.view_paths).to include(expected)
    end

    it 'throws an error if you try to repeat it' do
      expect {
        Jobs::Analysis::MockJob.add_concern 'NormalizeDocumentCounts'
      }.to raise_error(ArgumentError)
    end
  end

  describe '.view_paths' do
    it 'returns the base path' do
      expected = Rails.root.join('lib', 'jobs', 'analysis', 'views', 'mock_job')
      expect(Jobs::Analysis::MockJob.view_paths).to include(expected)
    end
  end

  describe '.job_list' do
    before(:each) do
      @jobs = Jobs::Analysis::Base.job_list
    end

    it 'returns a non-empty array' do
      expect(@jobs).not_to be_empty
    end

    it 'contains a class we know exists' do
      expect(@jobs).to include(Jobs::Analysis::ExportCitations)
    end
  end

end
