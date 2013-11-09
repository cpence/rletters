@javascript
Feature: Edit user account information
  As a registered user of the website
  I want to edit my user profile
  So that I can change my user information

    Scenario: Edit my account details
      Given I am logged in
      When I edit my account details
      Then I should see an account edited message
