# -*- encoding : utf-8 -*-

### GIVEN ###
Given(/^I have a pending analysis task$/) do
  expect(@dataset).to be

  @task = create(:analysis_task, dataset: @dataset)
end

Given(/^I have a failed analysis task$/) do
  expect(@dataset).to be

  @task = create(:analysis_task, dataset: @dataset, failed: true)
end

Given(/^I complete an analysis task for the dataset$/) do
  expect(@dataset).to be
  visit '/'
  click_link 'Start a new analysis'
  click_link 'How has the frequency of a term changed over time?'
  click_link 'Start'

  # This is an unfortunate hack, but modal dialogs will be the death of me
  @user.reload
  visit workflow_activate_path(class: @user.workflow_class,
                               link_dataset_id: @dataset.to_param)

  click_link 'Set Job Options'
  with_resque do
    click_button 'Start analysis job'
  end

  @dataset.reload
  expect(@dataset.analysis_tasks.size).to eq(1)
  @task = @dataset.analysis_tasks.first
  expect(@task.failed).to be false
  expect(@task.finished_at).to be
end

### WHEN ###
When(/^I clear the failed task$/) do
  expect(@dataset).to be
  expect(@task).to be

  visit dataset_path(@dataset)
  click_link '1 analysis task failed for this dataset! Click here to clear failed tasks.'

  @dataset.reload
  expect(@dataset.analysis_tasks).to be_empty
  expect(Datasets::AnalysisTask.exists?(@task)).to be false
  @task = nil
end

### THEN ###
Then(/^I should be able to start the task$/) do
  @task = @dataset.analysis_tasks.first

  if @task.nil?
    with_resque do
      click_button 'Start analysis job'

      # If the first page was task_datasets, then this could be task_params, in
      # which case we have to click the button again
      if page.has_button? 'Start analysis job'
        click_button 'Start analysis job'
      end
    end
  end

  @task = @dataset.analysis_tasks.first
  expect(@task).to be
end

Then(/^I should be able to view the results of the task$/) do
  expect(@dataset).to be
  expect(@task).to be

  visit dataset_path(@dataset)
  click_link 'View'

  expect(page).to have_content('Download in CSV format')

  visit dataset_path(@dataset)
end

Then(/^I should be able to delete the task$/) do
  expect(@dataset).to be
  expect(@task).to be

  visit dataset_path(@dataset)
  click_link 'Delete'

  @dataset.reload
  expect(@dataset.analysis_tasks).to be_empty
  expect(Datasets::AnalysisTask.exists?(@task)).to be false
  @task = nil
end
