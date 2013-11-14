# -*- encoding : utf-8 -*-

def find_dataset
  unless @user
    @dataset = nil
  else
    @dataset = @user.datasets.where(name: 'Cucumber Dataset').first
  end
end

### GIVEN ###
Given(/^I have a dataset$/) do
  @dataset = FactoryGirl.create(:full_dataset, name: 'Cucumber Dataset',
                                               working: true,
                                               user: @user)
end

Given(/^I have another dataset$/) do
  @other_dataset = FactoryGirl.create(:full_dataset, name: 'Other Dataset',
                                                     working: true,
                                                     user: @user)
end

Given(/^I have a dataset with (\d+) entries$/) do |entries|
  @dataset = FactoryGirl.create(:full_dataset,
                                working: true,
                                user: @user,
                                entries_count: Integer(entries))
end

### WHEN ###
When(/^I create a dataset from the current search$/) do
  expect(current_path).to eq(search_path)

  in_modal_dialog 'Create dataset from search' do
    with_resque do
      fill_in 'dataset_name', with: 'Cucumber Dataset'
      click_button 'Create Dataset'
    end
  end

  find_dataset
  expect(@dataset).to be
  expect(@dataset.disabled).to be false
end

When(/^I add the first article to the dataset$/) do
  expect(current_path).to eq(search_path)
  expect(@dataset).to be

  abbr = first('table.document-list td abbr.unapi-id')
  uid = abbr[:title]

  # This is an unfortunate hack, but modal dialogs will be the death of me
  params = "uid=#{Rack::Utils.escape(uid)}&_method=PATCH"
  script = <<EOS
var x = new XMLHttpRequest();
x.open('POST', '#{dataset_path(@dataset)}', false);
x.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
x.send('#{params}');
EOS
  page.execute_script(script)

  # The redirect here often doesn't work, patch it manually
  visit dataset_path(@dataset)

  expect(page).to have_content("Information for dataset — #{@dataset.name}")
end

When(/^I view the list of datasets$/) do
  visit '/datasets'
end

When(/^I visit the page for the dataset$/) do
  expect(@dataset).to be
  visit dataset_path(@dataset)
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
  @dataset.reload
  expect(@dataset.entries.count).to eq(Integer(entries))
end

Then(/^I should see the number of articles$/) do
  expect(page).to have_content("Number of documents: #{@dataset.entries.count}")
end

Then(/^I should see the list of analysis tasks$/) do
  if @dataset.analysis_tasks.present?
    expect(page).to have_selector('td', text: @dataset.analysis_tasks[0].name)
  else
    expect(page).to have_selector('td', text: 'No analysis tasks found')
  end
end

Then(/^I should see an alert for the pending task$/) do
  expect(page).to have_selector('.alert-box', text: '1 analysis task pending for this dataset...')
end

Then(/^I should see an alert for the failed task$/) do
  expect(page).to have_selector('.alert-box.alert', text: '1 analysis task failed for this dataset! Click here to clear failed tasks.')
end

Then(/^I should see no alert for the failed task$/) do
  expect(page).not_to have_selector('.alert-box.alert')
end
