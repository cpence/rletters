# frozen_string_literal: true
require 'test_helper'

class Datasets::TasksHelperTest < ActionView::TestCase
  test 'task_download_path' do
    task = create(:task, job_type: 'ExportCitationsJob')
    create(:file, task: task, description: 'test', short_description: 'test') do |f|
      f.from_string('{"abc":123}', filename: 'test.json',
                                   content_type: 'application/json')
    end

    assert_equal "/datasets/#{task.dataset.to_param}/tasks/#{task.to_param}/download/#{task.files.first.to_param}",
      task_download_path(task: task, content_type: 'application/json')
    assert_nil task_download_path(task: task, content_type: 'text/plain')
  end
end
