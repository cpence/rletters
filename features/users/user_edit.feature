@javascript
Feature: Edit User
  As a registered user of the website
  I want to edit my user profile
  So that I can change my user information

    Scenario: I sign in and edit my account
      Given I am logged in
      When I edit my account details
      Then I should see an account edited message
