# -*- encoding : utf-8 -*-

### GIVEN ###
Given(/^I have a pending analysis task$/) do
  expect(@dataset).to be

  @task = FactoryGirl.create(:analysis_task, dataset: @dataset)
end

Given(/^I have a failed analysis task$/) do
  expect(@dataset).to be

  @task = FactoryGirl.create(:analysis_task, dataset: @dataset,
                                             failed: true)
end

Given(/^I complete an analysis task for the dataset$/) do
  expect(@dataset).to be
  visit dataset_path(@dataset)

  with_resque do
    click_link('Plot dataset by date')
    click_button('Start analysis job')
  end

  @dataset.reload
  expect(@dataset.analysis_tasks.count).to eq(1)
  @task = @dataset.analysis_tasks.first
  expect(@task.failed).to be_false
  expect(@task.finished_at).to be
end

### WHEN ###
When(/^I start an analysis task for the dataset$/) do
  expect(@dataset).to be

  visit dataset_path(@dataset)
  click_link 'Plot dataset by date'
end

When(/^I start a multi\-dataset analysis task for the dataset$/) do
  expect(@dataset).to be
  expect(@other_dataset).to be

  visit dataset_path(@dataset)
  click_link 'Determine words that differentiate two datasets (Craig Zeta)'
end

When(/^I clear the failed task$/) do
  expect(@dataset).to be
  expect(@task).to be

  visit dataset_path(@dataset)
  click_link '1 analysis task failed for this dataset! Click here to clear failed tasks.'

  @dataset.reload
  expect(@dataset.analysis_tasks.count).to eq(0)
  expect(AnalysisTask.exists?(@task)).to be_false
  @task = nil
end

### THEN ###
Then(/^I should be able to select the second dataset for the task$/) do
  expect(@other_dataset).to be

  select @other_dataset.name, from: 'job_params_other_datasets_'
  with_resque { click_button 'Start analysis job' }
end

Then(/^I should be able to configure parameters for the task$/) do
  with_resque { click_button 'Start analysis job' }
end

Then(/^I should be able to start the task$/) do
  with_resque do
    if page.has_button? 'Start analysis job'
      click_button 'Start analysis job'
    end

    # If the first page was task_datasets, then this could be task_params, in
    # which case we have to click the button again
    if page.has_button? 'Start analysis job'
      click_button 'Start analysis job'
    end
  end

  expect(current_path).to eq(dataset_path(@dataset, trailing_slash: true))
  @task = @dataset.analysis_tasks.first
  expect(@task).to be
end

Then(/^I should be able to view the results of the task$/) do
  expect(@dataset).to be
  expect(@task).to be

  visit dataset_path(@dataset)
  click_link 'View Results'

  expect(page).to have_content('Download in CSV format')

  visit dataset_path(@dataset)
end

Then(/^I should be able to delete the task$/) do
  expect(@dataset).to be
  expect(@task).to be

  visit dataset_path(@dataset)
  click_link 'Delete Task'

  @dataset.reload
  expect(@dataset.analysis_tasks.count).to eq(0)
  expect(AnalysisTask.exists?(@task)).to be_false
  @task = nil
end
