
### WHEN ###
When /^I visit the search page$/ do
  visit '/search/'
end

When /^I search for articles$/ do
  visit '/search/'
  fill_in 'q', with: 'test'
end


### THEN ###
Then /^I should see a list of articles$/ do
  expect(page).to have_selector('table.document-list tr td')
end
