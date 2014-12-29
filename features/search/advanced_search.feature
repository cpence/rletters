@javascript
Feature: Advanced searching
  As a visitor to the website
  I want to be able to perform advanced searches
  So that I can narrow down documents very precisely

    Background:
      Given I am not logged in

    Scenario: Perform an advanced search
      When I run an advanced search for "Mark Twain" by the Authors field
      Then I should see a list of articles
        And the article list should contain Fenimore Cooper
