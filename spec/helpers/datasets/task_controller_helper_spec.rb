require 'rails_helper'

RSpec.describe Datasets::TaskControllerHelper, type: :helper do
  describe '#task_download_path' do
    before(:example) do
      @task = create(:task, job_type: 'ExportCitationsJob')
      @task.files.create!(description: 'test',
                          short_description: 'test') do |f|
        f.from_string('{"abc":123}', filename: 'test.json',
                                     content_type: 'application/json')
      end
      @task.reload
    end

    it 'returns a path to the file' do
      expect(helper.task_download_path(task: @task, content_type: 'application/json')).to \
        eq("/datasets/#{@task.dataset.to_param}/tasks/#{@task.to_param}/download/#{@task.files.first.to_param}")
    end

    it 'returns nil for missing content types' do
      expect(helper.task_download_path(task: @task, content_type: 'text/plain')).to be_nil
    end
  end
end
