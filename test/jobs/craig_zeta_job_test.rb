# frozen_string_literal: true
require 'test_helper'

class CraigZetaJobTest < ActiveJob::TestCase
  def perform
    dataset = create(:full_dataset, user: create(:user), num_docs: 1)
    dataset_2 = create(:full_dataset, user: dataset.user, num_docs: 1)
    @task = create(:task, dataset: dataset)
    CraigZetaJob.new.perform(@task, 'other_datasets' => [dataset_2.to_param])
  end

  include AnalysisJobHelper

  test 'should need two datasets' do
    assert_equal 2, CraigZetaJob.num_datasets
  end

  test 'should raise without enough datasets' do
    assert_raises(ArgumentError) do
      # Call perform manually, as this failure would otherwise be caught by
      # the failure handler
      CraigZetaJob.new.perform(create(:task))
    end
  end

  test 'should raise with too many datasets' do
    task = create(:task)
    dataset = create(:dataset, user: task.dataset.user)

    assert_raises(ArgumentError) do
      # Call perform manually, as this failure would otherwise be caught by
      # the failure handler
      CraigZetaJob.new.perform(task, 'other_datasets' => [dataset.to_param, dataset.to_param])
    end
  end

  test 'should work' do
    task = create(:task, dataset: create(:full_dataset, num_docs: 1))
    dataset_2 = create(:full_dataset, user: task.dataset.user, num_docs: 1)

    CraigZetaJob.perform_now(task,
                             'other_datasets' => [dataset_2.to_param])

    assert_equal 'Determine words that differentiate two datasets (Craig Zeta)', task.reload.name
    assert_equal 2, task.files.count
    refute_nil task.file_for('application/json')
    refute_nil task.file_for('text/csv')

    data = JSON.load(task.file_for('application/json').result.download)
    assert_kind_of Hash, data

    # Data is reasonable
    assert_equal 'Dataset', data['name_1']
    assert_equal 'Dataset', data['name_2']
    assert_kind_of Array, data['markers_1']
    assert_kind_of Array, data['markers_2']
    assert_kind_of Array, data['graph_points']
    assert_kind_of Array, data['zeta_scores']
  end

  test 'should create word clouds' do
    # Don't actually make word clouds; this is quite slow and we're testing
    # it elsewhere
    RLetters::Visualization::WordCloud.stubs(:call)
      .returns('this is totally a PDF')

    task = create(:task, dataset: create(:full_dataset, num_docs: 1))
    dataset_2 = create(:full_dataset, user: task.dataset.user, num_docs: 1)

    CraigZetaJob.perform_now(task,
                             'other_datasets' => [dataset_2.to_param],
                             'word_cloud' => '1')

    assert_equal 4, task.reload.files.count
    refute_nil task.file_for('application/json')
    refute_nil task.file_for('text/csv')
    refute_nil task.file_for('application/pdf')
  end
end
