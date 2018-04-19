require 'test_helper'

class Datasets::TaskTest < ActiveSupport::TestCase
  test 'should be invalid without name' do
    task = build_stubbed(:task, name: nil)

    refute task.valid?
  end

  test 'should be invalid without dataset' do
    task = build_stubbed(:task, dataset: nil)

    refute task.valid?
  end

  test 'should be invalid without job type' do
    task = build_stubbed(:task, job_type: nil)

    refute task.valid?
  end

  test 'should be valid with all parameters' do
    task = create(:task)

    assert task.valid?
  end

  test 'should return template path' do
    task = create(:task, job_type: 'ExportCitationsJob')
    path = task.template_path('test')

    assert_equal 'jobs/export_citations_job/test', path
  end

  test 'should default to nil finished_at' do
    task = create(:task)

    assert_nil task.finished_at
  end

  test 'should default to false failed' do
    task = create(:task)

    refute task.failed
  end

  test 'should return JSON when available' do
    task = create(:task, job_type: 'ExportCitationsJob')
    create(:file, task: task) do |f|
      f.from_string('{"abc":123}',
                    filename: 'test.json',
                    content_type: 'application/json')
    end

    assert_equal '{"abc":123}', task.reload.json
  end

  test 'should return nil when no JSON available' do
    task = create(:task, job_type: 'ExportCitationsJob')

    assert_nil task.json
  end

  test 'should associate with files' do
    task = create(:task)
    file = create(:file, task: task) do |f|
      f.from_string('test')
    end

    assert_equal 4, task.reload.files.first.result.byte_size
    assert_equal 'test', task.files.first.result.download
    assert_equal 'text/plain', task.files.first.result.content_type
  end

  test 'should return good job_class (class method)' do
    klass = Datasets::Task.job_class('ExportCitationsJob')

    assert_equal ExportCitationsJob, klass
  end

  test 'should raise error for bad job_class (class method)' do
    assert_raises(ArgumentError) do
      Datasets::Task.job_class('NotClass')
    end
  end

  test 'should return good job_class' do
    task = create(:task, job_type: 'ExportCitationsJob')

    assert_equal ExportCitationsJob, task.job_class
  end

  test 'should raise error for bad job_class' do
    task = create(:task)

    assert_raises(ArgumentError) do
      task.job_class
    end
  end

  test 'should default to nil job_id' do
    task = create(:task, job_type: 'ExportCitationsJob')

    assert_nil task.job_id
  end
end
