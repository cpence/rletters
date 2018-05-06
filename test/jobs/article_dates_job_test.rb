# frozen_string_literal: true
require 'test_helper'

class ArticleDatesJobTest < ActiveJob::TestCase
  def perform
    @task = create(:task)
    ArticleDatesJob.new.perform(@task)
  end

  include AnalysisJobHelper

  test 'should need one dataset' do
    assert_equal 1, ArticleDatesJob.num_datasets
  end

  test 'should work when not normalizing' do
    dataset = create(:full_dataset)
    create(:query, dataset: dataset, q: "uid:\"gutenberg:3172\"")
    task = create(:task, dataset: dataset)

    ArticleDatesJob.perform_now(task, 'normalize' => '0')

    assert_equal 'Plot number of articles by date', task.reload.name
    assert_equal 2, task.files.count
    refute_nil task.file_for('application/json')
    refute_nil task.file_for('text/csv')

    data = JSON.parse(task.json)
    assert_kind_of Hash, data

    # Data is reasonable
    assert_includes [2009, 1895], data['data'][0][0]
    assert_includes 1..5, data['data'][0][1]

    # Fills in intervening years between new and old documents with zeros
    refute_nil data['data'].find { |y| y[1] == 0}

    # Data is sorted by year
    assert_equal data['data'].sort_by { |d| d[0] }, data['data']
  end

  test 'should work when normalizing to corpus' do
    task = create(:task, dataset: create(:full_dataset))

    ArticleDatesJob.perform_now(task,
                                'normalize' => '1',
                                'normalization_dataset' => '')

    assert_equal 'Plot number of articles by date', task.reload.name
    assert_equal 2, task.files.count
    refute_nil task.file_for('application/json')
    refute_nil task.file_for('text/csv')

    data = JSON.parse(task.json)
    assert_kind_of Hash, data

    # Save the normalization set in the data
    assert_equal 'Entire Corpus', data['normalization_set']
    assert data['percent']

    # Data is reasonable
    assert_includes 1859..2012, data['data'][0][0]
    assert_includes 0..1, data['data'][0][1]

    # Fills in intervening years between new and old documents with zeros
    refute_nil data['data'].find { |y| y[1] == 0}

    # Data is sorted by year
    assert_equal data['data'].sort_by { |d| d[0] }, data['data']
  end

  test 'should work when normalizing to a dataset' do
    normalization_set = create(:full_dataset, num_docs: 10)
    task = create(:task, dataset: create(:full_dataset, user: normalization_set.user))

    ArticleDatesJob.perform_now(task,
                                'normalize' => '1',
                                'normalization_dataset' => normalization_set.to_param)

    assert_equal 'Plot number of articles by date', task.reload.name
    assert_equal 2, task.files.count
    refute_nil task.file_for('application/json')
    refute_nil task.file_for('text/csv')

    data = JSON.parse(task.json)
    assert_kind_of Hash, data

    # Save the normalization set in the data
    assert_equal normalization_set.name, data['normalization_set']
    assert data['percent']

    # Data is reasonable
    assert_includes 1859..2012, data['data'][0][0]
    assert_includes 0..1, data['data'][0][1]

    # Data is sorted by year
    assert_equal data['data'].sort_by { |d| d[0] }, data['data']
  end

  # We want to make sure it still works when we normalize to a dataset where
  # the dataset of interest isn't a subset
  test 'should work when normalizing badly' do
    normalization_set = create(:dataset)
    create(:query, dataset: normalization_set, q: "uid:\"gutenberg:3172\"")
    task = create(:task, dataset: create(:full_dataset, user: normalization_set.user))

    ArticleDatesJob.perform_now(task,
                                'normalize' => '1',
                                'normalization_dataset' => normalization_set.to_param)
    data = JSON.parse(task.reload.json)

    data['data'].each do |a|
      assert_equal 0, a[1]
    end
  end
end
