@javascript
Feature: Sign up for account
  In order to be able to save datasets and run analyses
  As a user
  I want to be able to sign up

    Background:
      Given I am not logged in

    Scenario: Sign up with valid data
      When I sign up with valid user data
      Then I should see a successful sign up message

    Scenario: Sign up with invalid e-mail address
      When I sign up with an invalid email
      Then I should see an invalid email message

    Scenario: Sign up without password
      When I sign up without a password
      Then I should see a missing password message

    Scenario: Sign up without password confirmation
      When I sign up without a password confirmation
      Then I should see a missing password confirmation message

    Scenario: Sign up with mismatched password and confirmation
      When I sign up with a mismatched password confirmation
      Then I should see a mismatched password message
