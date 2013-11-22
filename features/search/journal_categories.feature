@javascript
Feature: Journal categories
  As a visitor to the website
  I want to be able to browse journals by category
  So that I can refine my search

    Background:
      Given I am not logged in
        And there are categories:
          | name       | journals                            | parent |
          | Root       | Ethology; Genes, Brain and Behavior |        |
          | Eth        | Ethology                            | Root   |
          | GBB        | Genes, Brain and Behavior           | Root   |

    Scenario: Adding a journal category
      Given I visit the search page
      When I select the journal category "Eth"
      Then I should see 594 articles
        And I should see "Category: Eth" in the list of active filters

    Scenario: Clearing a category
      Given I visit the search page
        And I select the journal category "Eth"
        And I select the journal category "GBB"
      When I remove the category "GBB"
      Then I should see 594 articles
        And I should see "Category: Eth" in the list of active filters

    Scenario: Clearing all categories
      Given I visit the search page
        And I select the journal category "GBB"
      When I remove all filters
      Then I should see 1043 articles
        And there should be no filters active
