@javascript
Feature: Faceted browsing
  As a visitor to the website
  I want to be able to narrow my search by categories
  So that I can refine my search

    Background:
      Given I am not logged in

    Scenario: Faceted browsing by journal
      Given I visit the search page
      When I facet by the journal PLoS Neglected Tropical Diseases
      Then I should see 1500 articles
        And I should see "Journal: PLoS Neglected Tropical Diseases" in the list of active filters

    Scenario: Clearing a single facet
      Given I visit the search page
        And I facet by the journal PLoS Neglected Tropical Diseases
        And I facet by the author Peter J. Hotez
      When I remove the facet "Authors: Peter J. Hotez"
      Then I should see 1500 articles
        And I should see "Journal: PLoS Neglected Tropical Diseases" in the list of active filters

    Scenario: Clearing all facets
      Given I visit the search page
        And I facet by the journal PLoS Neglected Tropical Diseases
      When I remove all filters
      Then I should see 1502 articles
        And there should be no filters active
