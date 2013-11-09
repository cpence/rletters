
### WHEN ###
When(/^I start a new workflow analysis$/) do
  visit '/'
  click_link 'Start a new analysis'
end

When(/^I choose the (.*) task$/) do |task|
  map = {
    'plot dates' => 'How has the frequency of a term changed over time?',
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

  click_link 'Link an already created dataset'
  select @dataset.name, from: 'link_dataset_id'
  click_button 'Link dataset'

  # No matter how long we sleep here, this doesn't seem to go all the way away
  # on some clients (including and especially Travis).  This is a hack, but
  # let it go.
  sleep 3
  page.evaluate_script('$("div.reveal-modal-bg").hide()')
end

When(/^I link the other dataset$/) do
  expect(@other_dataset).to be

  click_link 'Link an already created dataset'
  select @other_dataset.name, from: 'link_dataset_id'
  click_button 'Link dataset'

  # No matter how long we sleep here, this doesn't seem to go all the way away
  # on some clients (including and especially Travis).  This is a hack, but
  # let it go.
  sleep 3
  page.evaluate_script('$("div.reveal-modal-bg").hide()')
end

When(/^I choose to create a new dataset$/) do
  click_link 'Create another dataset'
end

When(/^I confirm the data$/) do
  # Sometimes we may have screwed-up URLs here.  This is a hack, but it gets
  # us around some of our AJAX-dialog box trouble.
  click_link 'Current Analysis'

  within('.main') do
    if page.has_link? 'Start Analysis'
      with_resque { click_link 'Start Analysis' }
    else
      click_link 'Set Job Options'
    end
  end
end

When(/^I abort the workflow$/) do
  click_link 'Abort Building Analysis'
end

### THEN ###
Then(/^I should be able to fetch the workflow results$/) do
  within('nav') { click_link 'Fetch Results' }
  expect(page).to have_selector('td', text: @dataset.name)
end

Then(/^I should no longer be building a workflow$/) do
  expect(page).not_to have_link('Current Analysis')
end

Then(/^I should be able to view the result data$/) do
  click_link 'View Results'
  expect(page).to have_link('Download in CSV format')
end
