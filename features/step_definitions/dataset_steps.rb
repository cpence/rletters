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
  @dataset = FactoryGirl.create(:full_dataset, working: true,
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
  expect(current_path).to eq(search_path(trailing_slash: true))

  in_modal_dialog 'Create dataset from search' do
    with_resque do
      fill_in 'dataset_name', with: 'Cucumber Dataset'
      click_button 'Create Dataset'
    end
  end

  find_dataset
  expect(@dataset).to be
  expect(@dataset.disabled).to be_false
end

When(/^I add the first article to the dataset$/) do
  expect(current_path).to eq(search_path(trailing_slash: true))
  expect(@dataset).to be

  cell = first('table.document-list td')
  cell.click

  in_modal_dialog('Add this document to an existing dataset') do
    select @dataset.name, from: 'dataset_id'
    click_button 'Add'
  end
end

### THEN ###
Then(/^I should see the dataset in the list of datasets$/) do
  find_dataset
  expect(@dataset).to be

  visit '/datasets/'
  expect(page).to have_selector('td', text: "#{@dataset.name} #{@dataset.entries.size}")
end

Then(/^I should be able to view the dataset's properties$/) do
  find_dataset
  visit '/datasets/'

  click_link 'Manage'
  expect(page).to have_content("Information for dataset — #{@dataset.name}")
end

Then(/^the dataset should have (\d+) entries$/) do |entries|
  @dataset.reload
  expect(@dataset.entries.count).to eq(Integer(entries))
end
