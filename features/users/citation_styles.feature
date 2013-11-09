@javascript
Feature: Customized citation styles
  As a registered user of the website
  I want to customize the displayed citation style
  So that I can see my list of references as I choose

    Background:
      Given I am logged in

    Scenario: Set custom citation style
      When I select a custom citation style
        And I search for articles
      Then I should see the documents formatted with my style
