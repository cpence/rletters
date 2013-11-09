# -*- encoding : utf-8 -*-

### WHEN ###
When(/^I visit the search page$/) do
  visit '/search/'
end

When(/^I search for articles$/) do
  visit '/search/'
  fill_in 'q', with: 'test'
  submit_form 'search_form'
end

When(/^I run an advanced search for the ([a-z_]+) (.*)$/) do |field, content|
  visit '/search/advanced/'
  fill_in field, with: content
  click_button 'Perform advanced search'
end

When(/^I run a Solr query search for '(.*)'$/) do |query|
  visit '/search/advanced/'
  fill_in 'q', with: query
  click_button 'Perform Solr query'
end

When(/^I facet by the ([a-z_]+) (.*)$/) do |field, content|
  within('.side-nav') do
    click_link content
  end
end

When(/^I remove the facet "(.*?)"$/) do |facet|
  within('dl.sub-nav') do
    click_link facet
  end
end

When(/^I remove all facets$/) do
  within('dl.sub-nav') do
    click_link('Remove All')
  end
end

When(/^I sort by ([a-z_]+) \((ascending|descending)\)$/) do |field, dir|
  click_link('Sort: Year (descending)', match: :first)
  click_link("Sort: #{field.titlecase} (#{dir})")
end

### THEN ###
Then(/^I should see a list of articles$/) do
  expect(page).to have_selector('table.document-list tr td')
end

Then(/^I should see the number of articles found$/) do
  expect(page).to have_content(/\d+ articles found/)
end

Then(/^the article list should contain (.*)$/) do |content|
  element = find('table.document-list')
  expect(element).to have_content(content)
end

Then(/^I should see (\d+) articles$/) do |num|
  expect(page).to have_content("#{num} articles")
end

Then(/^I should see "(.*?)" in the list of active facets$/) do |facet|
  expect(page).to have_selector('dd a', text: /#{facet}/)
end

Then(/^there should be no filters active$/) do
  expect(page).to have_selector('dd a', text: 'No filters active')
end
