require 'test_helper'

class UserExportJobTest < ActiveJob::TestCase
  test 'should export all user data' do
    user = create(:user)

    # One library entry
    library = create(:library, user: user, name: 'A library', url: 'https://google.com?')

    # Three datasets
    dataset_1 = create(:full_dataset, name: 'First Dataset', num_docs: 3, user: user)
    dataset_2 = create(:full_dataset, name: 'Second Dataset', num_docs: 3, user: user)
    dataset_3 = create(:full_dataset, name: 'Empty Dataset', num_docs: 3, user: user)

    # One has two tasks, two has one task
    task_1_1 = create(:task, dataset: dataset_1, job_type: 'ExportCitationsJob', finished_at: DateTime.now)
    task_1_2 = create(:task, dataset: dataset_1, job_type: 'MultipleFilesJob', finished_at: DateTime.now)
    task_2_1 = create(:task, dataset: dataset_2, job_type: 'ExportCitationsJob', finished_at: DateTime.now)

    # Both the first tasks have a file with the same name, to test collision
    file_1_1 = create(:file, task: task_1_1)
    file_2_1 = create(:file, task: task_2_1)
    file_1_1.from_string('these two will have the same content_type and filename')
    file_2_1.from_string('these two will have the same content_type and filename')

    # The second task has multiple files
    file_1_2_1 = create(:file, task: task_1_2)
    file_1_2_1.from_string('this is a first one', filename: 'something.csv', content_type: 'text/csv')
    file_1_2_2 = create(:file, task: task_1_2)
    file_1_2_2.from_string('this is another one', filename: 'out.txt', content_type: 'text/plain')
    file_1_2_3 = create(:file, task: task_1_2)
    file_1_2_3.from_string('this is a last one', filename: 'woot.json', content_type: 'application/json')

    # And do the export
    UserExportJob.perform_now(user)

    assert_equal 'export.zip', user.export_archive.filename.to_s
    assert_equal 'application/zip', user.export_archive.content_type
    assert user.export_archive.byte_size > 0

    # Unpack the zip into a hash
    zip_contents = {}
    data = user.export_archive.download
    ::Zip::InputStream.open(StringIO.new(data)) do |zis|
      while (entry = zis.get_next_entry)
        zip_contents[entry.name] = zis.read
      end
    end

    # Parse some bits from everything and check some random spots
    user_json = zip_contents['user.json']
    assert user_json

    user_hash = JSON.parse(user_json)
    assert_equal user.name, user_hash['name']
    assert_equal user.email, user_hash['email']

    libraries_json = zip_contents['libraries.json']
    assert libraries_json

    libraries_array = JSON.parse(libraries_json)
    assert_kind_of Array, libraries_array
    assert_kind_of Hash, libraries_array[0]
    assert_equal 'A library', libraries_array[0]['name']

    datasets_json = zip_contents['datasets.json']
    assert datasets_json

    datasets_array = JSON.parse(datasets_json)
    assert_kind_of Array, datasets_array
    assert_equal 3, datasets_array.count

    dataset_1_hash = datasets_array.find { |h| h['name'] == 'First Dataset' }
    dataset_2_hash = datasets_array.find { |h| h['name'] == 'Second Dataset' }
    dataset_3_hash = datasets_array.find { |h| h['name'] == 'Empty Dataset' }

    assert dataset_1_hash
    assert dataset_2_hash
    assert dataset_3_hash

    assert_equal 1, dataset_1_hash['queries'].count
    assert_kind_of String, dataset_2_hash['queries'][0]['q']
    assert_empty dataset_3_hash['tasks']

    assert_equal 2, dataset_1_hash['tasks'].count

    big_task = dataset_1_hash['tasks'].find { |t| t['files'].count == 3 }
    small_task = dataset_1_hash['tasks'].find { |t| t['files'].count == 1 }

    assert big_task
    assert small_task

    assert_equal 1, dataset_2_hash['tasks'].count
    assert_equal 1, dataset_2_hash['tasks'][0]['files'].count

    # Make sure two files with the same name in two different tasks get two
    # different filenames
    assert_not_equal small_task['files'][0], dataset_2_hash['tasks'][0]['files'][0]

    # And make sure all the files are actually present, too
    big_task['files'].each do |f|
      assert zip_contents[f]
    end
    assert zip_contents[small_task['files'][0]]
    assert zip_contents[dataset_2_hash['tasks'][0]['files'][0]]

    assert_equal 8, zip_contents.count
  end
end
