# frozen_string_literal: true
require 'test_helper'

class NetworkJobTest < ActiveJob::TestCase
  def perform
    @task = create(:task, dataset: create(:dataset))
    create(:query, dataset: @task.dataset, q: "uid:\"#{WORKING_UIDS[2]}\"")
    NetworkJob.new.perform(@task, 'focal_word' => 'diseases')
  end

  include AnalysisJobHelper

  test 'should need one dataset' do
    assert_equal 1, NetworkJob.num_datasets
  end

  test 'should work' do
    task = create(:task, dataset: create(:dataset))
    create(:query, dataset: task.dataset, q: "uid:\"#{WORKING_UIDS[2]}\"")

    NetworkJob.perform_now(task, 'focal_word' => 'diseases')

    assert_equal 'Compute network of associated terms', task.reload.name

    data = JSON.parse(task.json)
    assert_kind_of Hash, data

    assert_equal 'Dataset', data['name']
    assert_equal 'diseases', data['focal_word']

    progress_node = data['d3_nodes'].index { |n| n['name'] == 'progress' }
    diseas_node = data['d3_nodes'].index { |n| n['name'] == 'diseas' }

    edge = data['d3_links'].find do |l|
      l['source'] == progress_node && l['target'] == diseas_node
    end

    assert_in_epsilon 0.625, edge['strength']
  end
end
