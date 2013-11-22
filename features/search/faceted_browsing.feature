@javascript
Feature: Faceted browsing
  As a visitor to the website
  I want to be able to narrow my search by categories
  So that I can refine my search

    Background:
      Given I am not logged in

    Scenario: Faceted browsing by journal
      Given I visit the search page
      When I facet by the journal Ethology
      Then I should see 594 articles
        And I should see "Journal: Ethology" in the list of active filters

    Scenario: Clearing a single facet
      Given I visit the search page
        And I facet by the journal Ethology
        And I facet by the author Michael H. Ferkin
      When I remove the facet "Authors: Michael H. Ferkin"
      Then I should see 594 articles
        And I should see "Journal: Ethology" in the list of active filters

    Scenario: Clearing all facets
      Given I visit the search page
        And I facet by the journal Ethology
      When I remove all filters
      Then I should see 1043 articles
        And there should be no filters active
