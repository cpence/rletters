# -*- encoding : utf-8 -*-

### WHEN ###
When /^I visit the search page$/ do
  visit '/search/'
end

When /^I search for articles$/ do
  visit '/search/'
  fill_in 'q', with: 'test'
  submit_form 'search_form'
end

When /^I run an advanced search for the ([a-z_]+) (.*)$/ do |field, content|
  visit '/search/advanced/'
  fill_in field, with: content
  click_button 'Perform advanced search'
end


### THEN ###
Then /^I should see a list of articles$/ do
  expect(page).to have_selector('table.document-list tr td')
end

Then /^I should see the number of articles found$/ do
  expect(page).to have_content(/\d+ articles found/)
end

Then /^the article list should contain (.*)$/ do |content|
  element = find('table.document-list')
  expect(element).to have_content(content)
end
