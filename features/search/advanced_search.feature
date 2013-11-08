@javascript
Feature: Advanced Search
  As a visitor to the website
  I want to be able to perform advanced searches
  So that I can narrow down documents very precisely

    Background:
      Given I am not logged in

    Scenario: I perform an advanced search
      When I run an advanced search for the authors Mark Twain
      Then I should see a list of articles
        And the article list should contain Fenimore Cooper
