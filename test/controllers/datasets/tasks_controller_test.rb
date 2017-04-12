require 'test_helper'

class Datasets::TasksControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    get dataset_tasks_url(dataset_id: dataset.to_param)

    assert_response :success
  end

  test 'should not get index for invalid dataset' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    get dataset_tasks_url(dataset_id: 'asdf')

    assert_response 404
  end

  test 'should not get new for invalid class' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    get new_dataset_task_url(dataset_id: dataset.to_param,
                             class: 'ThisIsNoClass')

    assert_response 500
  end

  test 'should not get new for Base class' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    get new_dataset_task_url(dataset_id: dataset.to_param,
                             class: 'Base')

    assert_response 500
  end

  test 'should get new for one-dataset class' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    get new_dataset_task_url(dataset_id: dataset.to_param,
                             class: 'ExportCitationsJob',
                             job_params: { format: 'bibtex' })

    assert_response :success
  end

  test 'should get new for two-dataset class' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    dataset_2 = create(:full_dataset, user: user, working: true)
    sign_in user

    get new_dataset_task_url(dataset_id: dataset.to_param,
                             class: 'CraigZetaJob',
                              job_params: {
                                other_datasets: [dataset_2.to_param]
                              })

    assert_response :success
  end

  test 'should not get new for two-dataset class with one missing' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    get new_dataset_task_url(dataset_id: dataset.to_param,
                             class: 'CraigZetaJob')

    assert_response 500
  end

  test 'should not create task with invalid class' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    post dataset_tasks_url(dataset_id: dataset.to_param,
                           class: 'ThisIsNoClass')

    assert_response 500
  end

  test 'should not create task with Base class' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    post dataset_tasks_url(dataset_id: dataset.to_param,
                           class: 'Base')

    assert_response 500
  end

  test 'should create task when valid class and no params passed' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    post dataset_tasks_url(dataset_id: dataset.to_param,
                           class: 'NamedEntitiesJob')

    assert_redirected_to dataset_url(id: dataset.to_param)
    refute_empty dataset.reload.tasks.first.job_id
  end

  test 'should create task when valid class and params passed' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    post dataset_tasks_url(dataset_id: dataset.to_param,
                           class: 'ExportCitationsJob',
                           job_params: { format: 'bibtex' })

    assert_redirected_to dataset_url(id: dataset.to_param)
    refute_empty dataset.reload.tasks.first.job_id
  end

  test 'should create task as part of workflow' do
    user = create(:user,
                  workflow_active: true,
                  workflow_class: 'ExportCitationsJob')
    dataset = create(:full_dataset, user: user, working: true)
    user.workflow_datasets = [dataset.to_param]
    user.save
    sign_in user

    post dataset_tasks_url(dataset_id: dataset.to_param,
                           class: 'ExportCitationsJob',
                           job_params: { format: 'bibtex' })

    assert_redirected_to root_url
    refute user.reload.workflow_active
    assert_nil user.workflow_class
    assert_empty user.workflow_datasets
  end

  test 'should not get view when invalid task passed' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    get view_dataset_task_url(dataset_id: dataset.to_param,
                              id: '12345678',
                              template: 'test')

    assert_response 404
  end

  test 'should not get view when invalid template passed' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    task = create(:task, dataset: dataset, job_type: 'ExportCitationsJob')
    sign_in user

    get view_dataset_task_url(dataset_id: dataset.to_param,
                              id: task.to_param,
                              template: 'notaview')

    assert_response 500
  end

  test 'should get view' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    task = create(:task, dataset: dataset, job_type: 'ExportCitationsJob')
    sign_in user

    get view_dataset_task_url(dataset_id: dataset.to_param,
                              id: task.to_param,
                              template: '_params')

    assert_response :success
    assert_includes @response.body, '<option'
  end

  test 'should not get download with invalid id' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    get download_dataset_task_url(dataset_id: dataset.to_param,
                                  id: '12345678',
                                  file: '0')

    assert_response 404
  end

  test 'should not get download with invalid file number' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    task = create(:task, dataset: dataset, job_type: 'ExportCitationsJob')
    sign_in user

    get download_dataset_task_url(dataset_id: dataset.to_param,
                                  id: task.to_param,
                                  file: 'asdfasdf')

    assert_response 404
  end

  test 'should not get download with non-downloadable file' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    task = create(:task, dataset: dataset, job_type: 'ExportCitationsJob')
    file = create(:file, task: task, downloadable: false)
    file.from_string('test')
    sign_in user

    get download_dataset_task_url(dataset_id: dataset.to_param,
                                  id: task.to_param,
                                  file: file.to_param)

    assert_response 404
  end

  test 'should get download for a valid file' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    task = create(:task, dataset: dataset, job_type: 'ExportCitationsJob')
    sign_in user

    ExportCitationsJob.new.perform(task, format: 'bibtex')
    file = task.files.first

    get download_dataset_task_url(dataset_id: dataset.to_param,
                                  id: task.to_param,
                                  file: file.to_param)

    assert_response :success
    assert_equal 'application/zip', @response.content_type
    assert @response.body.length > 0
  end

  test 'should not destroy for invalid id' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    sign_in user

    delete dataset_task_url(dataset_id: dataset.to_param,
                            id: '12345678')

    assert_response 404
  end

  test 'should delete task' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, working: true)
    task = create(:task, dataset: dataset, job_type: 'ExportCitationsJob')
    sign_in user

    assert_difference('Datasets::Task.count', -1) do
      delete dataset_task_url(dataset_id: dataset.to_param,
                              id: task.to_param),
             env: { 'HTTP_REFERER' => workflow_fetch_path }
    end

    assert_redirected_to(workflow_fetch_path)
  end
end
