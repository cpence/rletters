require 'test_helper'

class ExportCitationsJobTest < ActiveJob::TestCase
  def perform
    @task = create(:task)
    ExportCitationsJob.new.perform(@task, 'format' => 'bibtex')
  end

  include AnalysisJobHelper

  test 'should need one dataset' do
    assert_equal 1, ExportCitationsJob.num_datasets
  end

  test 'should raise with invalid format' do
    assert_raises(KeyError) do
      ExportCitationsJob.new.perform(create(:task), format: 'notaformat')
    end
  end

  test 'should work' do
    task = create(:task, dataset: create(:full_dataset, num_docs: 10))

    ExportCitationsJob.perform_now(task, 'format' => 'bibtex')

    assert_equal 'Export dataset as citations', task.reload.name

    # Make sure it made the right number of entries in the ZIP
    data = task.file_for('application/zip').result.file_contents(:original)
    entries = 0
    ::Zip::InputStream.open(StringIO.new(data)) do |zis|
      entries += 1 while zis.get_next_entry
    end
    assert_equal 10, entries
  end
end
