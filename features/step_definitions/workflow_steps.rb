# -*- encoding : utf-8 -*-

### WHEN ###
When(/^I start a new workflow analysis$/) do
  visit '/'
  click_link 'Start a new analysis'
end

When(/^I choose the (.*) task$/) do |task|
  map = {
    'article dates' => 'When were a given set of articles published?',
    'Craig Zeta' => 'Given two sets of articles, what words mark out an article'
  }

  link_text = map[task]
  expect(link_text).to be

  click_link link_text
end

When(/^I confirm the choice$/) do
  click_link 'Start'
end

When(/^I link the dataset$/) do
  expect(@dataset).to be

  # This is an unfortunate hack, but modal dialogs will be the death of me
  @user.reload
  visit workflow_activate_path(class: @user.workflow_class,
                               link_dataset_id: @dataset.to_param)
end

When(/^I link the other dataset$/) do
  expect(@other_dataset).to be

  # This is an unfortunate hack, but modal dialogs will be the death of me
  @user.reload
  visit workflow_activate_path(class: @user.workflow_class,
                               link_dataset_id: @other_dataset.to_param)
end

When(/^I choose to create a new dataset$/) do
  click_link 'Create another dataset'
end

When(/^I confirm the data$/) do
  @user.reload
  good_path = workflow_activate_path(class: @user.workflow_class)
  if current_path != good_path
    # This can occasionally be called without being on the activation page,
    # for example, when creating new datasets for workflows
    visit good_path
  end

  within('.main') do
    if page.has_link? 'Start Analysis'
      click_link 'Start Analysis'
    else
      click_link 'Set Job Options'
    end
  end
end

When(/^I abort the workflow$/) do
  click_link 'Abort Building Analysis'
end

When(/^I visit the status page$/) do
  within('nav') { click_link 'Fetch' }
end

### THEN ###
Then(/^I should see the status of my task$/) do
  expect(page).to have_selector('td', text: '40%: Pending task...')
end

Then(/^I should be able to fetch the workflow results$/) do
  within('nav') { click_link 'Fetch' }
  expect(page).to have_selector('td', text: @dataset.name)
end

Then(/^I should no longer be building a workflow$/) do
  expect(page).not_to have_link('Current Analysis')
end

Then(/^I should be able to view the result data$/) do
  click_link 'View'
  expect(page).to have_link('Download in CSV format')
end
