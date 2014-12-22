@javascript
Feature: Journal categories
  As a visitor to the website
  I want to be able to browse journals by category
  So that I can refine my search

    Background:
      Given I am not logged in
        And there are categories:
          | name       | journals                                    | parent |
          | Root       | PLoS Neglected Tropical Diseases; Gutenberg |        |
          | PNTD       | PLoS Neglected Tropical Diseases            | Root   |
          | Gutenberg  | Gutenberg                                   | Root   |

    Scenario: Adding a journal category
      Given I visit the search page
      When I select the journal category "PNTD"
      Then I should see 1500 articles
        And I should see "Category: PNTD" in the list of active filters

    Scenario: Clearing a category
      Given I visit the search page
        And I select the journal category "PNTD"
        And I select the journal category "Gutenberg"
      When I remove the category "Gutenberg"
      Then I should see 1500 articles
        And I should see "Category: PNTD" in the list of active filters

    Scenario: Clearing all categories
      Given I visit the search page
        And I select the journal category "Gutenberg"
      When I remove all filters
      Then I should see 1502 articles
        And there should be no filters active
