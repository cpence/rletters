# frozen_string_literal: true

require 'application_system_test_case'

class PendingTaskTest < ApplicationSystemTestCase
  test 'workflow with pending task' do
    sign_in_with
    create_dataset
    visit datasets_path

    create(:task, dataset: Dataset.first, finished_at: nil,
                  progress: 0.4, progress_message: 'Pending task...')

    within('.navbar') { click_link 'Fetch' }
    assert_selector 'td', text: '40%: Pending task...'
  end

  test 'workflow with failed task' do
    sign_in_with
    create_dataset
    visit datasets_path

    create(:task, dataset: Dataset.first, finished_at: nil, failed: true,
                  name: 'Blahdeblah')

    within('.navbar') { click_link 'Fetch' }
    assert_selector 'td', text: 'Blahdeblah'
    assert_selector 'td', text: 'Task failed'
  end
end
