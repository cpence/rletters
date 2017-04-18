require 'test_helper'

class NamedEntitiesJobTest < ActiveJob::TestCase
  setup do
    @old_path = ENV['NLP_TOOL_PATH']
    ENV['NLP_TOOL_PATH'] = 'stubbed'

    @entities = build(:named_entities)
    RLetters::Analysis::NLP.stubs(:named_entities).returns(@entities)
  end

  teardown do
    ENV['NLP_TOOL_PATH'] = @old_path
  end

  def perform
    @task = create(:task)
    NamedEntitiesJob.new.perform(@task)
  end

  include AnalysisJobHelper

  test 'should need one dataset' do
    assert_equal 1, NamedEntitiesJob.num_datasets
  end

  test 'should be available when NLP is available' do
    assert NamedEntitiesJob.available?
  end

  test 'should be unavailable when NLP is not available' do
    ENV['NLP_TOOL_PATH'] = nil
    refute NamedEntitiesJob.available?
  end

  test 'should work' do
    task = create(:task, dataset: create(:full_dataset))

    NamedEntitiesJob.perform_now(task)

    assert_equal 'Extract references to proper names', task.reload.name
    assert_equal 2, task.files.count
    refute_nil task.file_for('application/json')
    refute_nil task.file_for('text/csv')

    data = JSON.load(task.file_for('application/json').result.file_contents(:original))
    assert_kind_of Hash, data

    assert_includes data['data'], 'PERSON'
    assert_kind_of Array, data['data']['PERSON']
    refute_empty data['data']['PERSON']
  end

  test 'should still work when NLP fails' do
    RLetters::Analysis::NLP.stubs(:named_entities).returns({})
    NamedEntitiesJob.perform_now(create(:task, dataset: create(:full_dataset)))
  end
end
