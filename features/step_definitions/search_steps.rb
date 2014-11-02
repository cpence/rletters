# -*- encoding : utf-8 -*-

### GIVEN ###
Given(/^there are categories:$/) do |table|
  # We have to rely on the user to create these in order!
  table.hashes.each do |category|
    journals = category['journals'].split(';').map(&:strip)

    if category['parent'].present?
      parent = Documents::Category.find_by!(name: category['parent'])
      parent.children.create(name: category['name'], journals: journals)
    else
      Documents::Category.create(name: category['name'], journals: journals)
    end
  end
end

### WHEN ###
When(/^I visit the search page$/) do
  visit '/search'
end

When(/^I search for articles$/) do
  visit '/search'
  fill_in 'q', with: 'test'
  submit_form 'search_form'
end

When(/^I run an advanced search for the ([a-z_]+) (.*)$/) do |field, content|
  visit '/search/advanced'
  fill_in field, with: content
  click_button 'Perform advanced search'
end

When(/^I run a Solr query search for '(.*)'$/) do |query|
  visit '/search/advanced'
  fill_in 'q', with: query
  click_button 'Perform Solr query'
end

When(/^I facet by the ([a-z_]+) (.*)$/) do |field, content|
  within('.well .nav') do
    click_link content
  end
end

When(/^I remove the facet "(.*?)"$/) do |facet|
  within('.main .navbar') do
    click_link facet
  end
end

When(/^I select the journal category "(.*?)"$/) do |category|
  within('.well .nav') do
    click_link(category)
  end
end

When(/^I remove the category "(.*?)"$/) do |category|
  within('.well .nav') do
    click_link(category)
  end
end

When(/^I remove all filters$/) do
  within('.main .navbar') do
    click_link('Remove All')
  end
end

When(/^I sort by ([a-z_]+) \((ascending|descending)\)$/) do |field, dir|
  click_link('Sort', match: :first)
  click_link("Sort: #{field.titlecase} (#{dir})")
end

### THEN ###
Then(/^I should see a list of articles$/) do
  expect(page).to have_selector('table.document-list tr td')
end

Then(/^I should see the number of articles found$/) do
  expect(page).to have_content(/\d+ articles found/i)
end

Then(/^the article list should contain (.*)$/) do |content|
  element = find('table.document-list')
  expect(element).to have_content(content)
end

Then(/^I should see the documents formatted with my style$/) do
  expect(page).to have_content('Woodward, Raymond L., Michelle K. Schmick, and Michael H. Ferkin. 1999. “Response of Prairie Voles, Microtus ochrogaster (Rodentia, Arvicolidae), to Scent Over-marks of Two Same-sex Conspecifics: A Test of the Scent-masking Hypothesis.” Ethology 105: 1009–1017.')
end

Then(/^I should see (\d+) articles$/) do |num|
  expect(page).to have_content(/#{num} articles /i)
end

Then(/^I should see "(.*?)" in the list of active filters$/) do |facet|
  expect(page).to have_selector('.main .navbar .navbar-btn', text: /#{facet}/)
end

Then(/^there should be no filters active$/) do
  expect(page).to have_selector('.main .navbar .navbar-btn', text: 'No filters active')
end
