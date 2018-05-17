# frozen_string_literal: true

require 'test_helper'

module Datasets
  class TasksHelperTest < ActionView::TestCase
    test 'task_download_path works' do
      task = create(:task, job_type: 'ExportCitationsJob')
      create(:file, task: task, description: 'test', short_description: 'test') do |f|
        f.from_string('{"abc":123}', filename: 'test.json',
                                     content_type: 'application/json')
      end

      assert_includes task_download_path(task: task, content_type: 'application/json'),
                      'rails/active_storage'
      assert_nil task_download_path(task: task, content_type: 'text/plain')
    end
  end
end
