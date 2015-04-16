
def find_dataset
  if @user
    @dataset = @user.datasets.where(name: 'Cucumber Dataset').first
  else
    @dataset = nil
  end
end

### GIVEN ###
Given(/^I have a dataset$/) do
  @dataset = create(:full_dataset, name: 'Cucumber Dataset', working: true,
                                   user: @user)
end

Given(/^I have another dataset$/) do
  @other_dataset = create(:full_dataset, name: 'Other Dataset', working: true,
                                         user: @user)
end

Given(/^I have a dataset with (\d+) entries$/) do |entries|
  @dataset = create(:full_dataset, working: true, user: @user,
                                   entries_count: Integer(entries))
end

### WHEN ###
When(/^I create a dataset from the current search$/) do
  expect(current_path).to eq(search_path)

  # No clue why this (the correct code here) is failing
  # click_link 'Save Results'
  # find('.modal-dialog')

  link = find(:link, 'Save Results')
  visit(link[:href])

  fill_in 'dataset_name', with: 'Cucumber Dataset'
  click_button 'Create Dataset'

  find_dataset
  expect(@dataset).to be
  expect(@dataset.disabled).to be false
end

When(/^I add the first article to the dataset$/) do
  expect(current_path).to eq(search_path)
  expect(@dataset).to be

  # Hack our way directly to the submit button on the first dataset's modal
  # dialog, which is hanging out at the bottom of the page
  first('#modal-container div.modal .modal-footer button', visible: false).trigger('click')
  expect(page).to have_content("Information for dataset — #{@dataset.name}")
end

When(/^I view the list of datasets$/) do
  visit '/datasets'
end

When(/^I visit the page for the dataset$/) do
  expect(@dataset).to be
  visit dataset_path(@dataset)

  expect(page).to have_selector('div#dataset-task-list')
  expect(page).to have_selector('div#dataset-task-list table.button-table')
end

When(/^I delete the dataset$/) do
  find_dataset
  click_link 'Delete'
end

### THEN ###
Then(/^I should see the dataset in the list of datasets$/) do
  find_dataset
  expect(@dataset).to be

  visit '/datasets/'
  expect(page).to have_selector('td', text: "#{@dataset.name} #{@dataset.entries.size}")
end

Then(/^I should see no datasets in the list of datasets$/) do
  visit '/datasets'
  expect(page).to have_selector('td', text: 'No datasets')
end

Then(/^I should be able to view the dataset's properties$/) do
  find_dataset
  visit '/datasets'

  click_link 'Manage'
  expect(page).to have_content("Information for dataset — #{@dataset.name}")
end

Then(/^the dataset should have (\d+) entries$/) do |entries|
  visit '/datasets'

  cell = page.find('td.label-cell', text: /#{Regexp.escape(@dataset.name)}/)
  expect(cell).to have_selector('span.label', text: entries.to_s)

  @dataset.reload
end

Then(/^I should see the number of articles$/) do
  expect(page).to have_content("Number of documents: #{@dataset.entries.size}")
end

Then(/^I should see the list of analysis tasks$/) do
  if @dataset.analysis_tasks.present?
    expect(page).to have_selector('td', text: @dataset.analysis_tasks[0].name)
  else
    expect(page).to have_selector('td', text: 'No analysis tasks found')
  end
end

Then(/^I should see an alert for the pending task$/) do
  expect(page).to have_selector('.alert', text: '1 analysis task pending for this dataset...')
end

Then(/^I should see an alert for the failed task$/) do
  expect(page).to have_selector('.alert.alert-danger', text: '1 analysis task failed for this dataset! Click here to clear failed tasks.')
end

Then(/^I should see no alert for the failed task$/) do
  expect(page).not_to have_selector('.alert.alert-danger')
end
