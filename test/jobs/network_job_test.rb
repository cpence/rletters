require 'test_helper'

class NetworkJobTest < ActiveJob::TestCase
  def perform
    @task = create(:task, dataset: create(:dataset))
    create(:query, dataset: @task.dataset, q: "uid:\"#{WORKING_UIDS[2]}\"")
    create(:stop_list)
    NetworkJob.new.perform(@task, 'focal_word' => 'diseases')
  end

  include AnalysisJobHelper

  test 'should need one dataset' do
    assert_equal 1, NetworkJob.num_datasets
  end

  test 'should work' do
    task = create(:task, dataset: create(:dataset))
    create(:query, dataset: task.dataset, q: "uid:\"#{WORKING_UIDS[2]}\"")
    create(:stop_list)

    NetworkJob.perform_now(task, 'focal_word' => 'diseases')

    assert_equal 'Compute network of associated terms', task.reload.name

    data = JSON.load(task.file_for('application/json').result.file_contents(:original))
    assert_kind_of Hash, data

    assert_equal 'Dataset', data['name']
    assert_equal 'diseases', data['focal_word']
    assert_in_epsilon 0.7142857142857143, data['d3_links'][0]['strength']
  end
end
