# -*- encoding : utf-8 -*-

def find_dataset
  unless @user
    @dataset = nil
  else
    @dataset = @user.datasets.where(name: 'Cucumber Dataset').first
  end
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
