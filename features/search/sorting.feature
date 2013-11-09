@javascript
Feature: Sorting the list of results
  As a visitor to the website
  I want to be able to sort the list of results
  So that I can refine my search

    Background:
      Given I am not logged in

    Scenario: Choosing a new sort method
      Given I visit the search page
      When I sort by authors (ascending)
      Then the article list should contain Expression of Thanks
