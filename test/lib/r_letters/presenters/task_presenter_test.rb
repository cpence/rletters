require 'test_helper'

class TaskPresenterTest < ActiveSupport::TestCase
  test 'json_escaped works if available' do
    task = create(:task, job_type: 'ExportCitationsJob')
    task.files.create!(description: 'test',
                       short_description: 'test') do |f|
      f.from_string('{"abc":123}', filename: 'test.json',
                                   content_type: 'application/json')
    end
    task.reload
    pres = RLetters::Presenters::TaskPresenter.new(task: task)

    assert_equal '{\"abc\":123}', pres.json_escaped
  end

  test 'json_escaped is nil if not available' do
    task = create(:task, job_type: 'ExportCitationsJob')
    pres = RLetters::Presenters::TaskPresenter.new(task: task)

    assert_nil pres.json_escaped
  end

  test 'status_message works with both percent and message' do
    task = stub(progress: 0.3, progress_message: 'Going')
    pres = RLetters::Presenters::TaskPresenter.new(task: task)

    assert_equal '30%: Going', pres.status_message
  end

  test 'status_message works with only percent' do
    task = stub(progress: 0.3, progress_message: nil)
    pres = RLetters::Presenters::TaskPresenter.new(task: task)

    assert_equal '30%', pres.status_message
  end

  test 'status_message works with only message' do
    task = stub(progress: nil, progress_message: 'Going')
    pres = RLetters::Presenters::TaskPresenter.new(task: task)

    assert_equal 'Going', pres.status_message
  end
end
