@javascript
Feature: Sign in to account
  In order to be able to save datasets and run analyses
  A user
  Should be able to sign in

    Scenario: Sign in without signing up
      Given I do not exist as a user
      When I sign in with valid credentials
      Then I see an invalid login message
        And I should be signed out

    Scenario: Sign in successfully
      Given I exist as a user
        And I am not logged in
      When I sign in with valid credentials
      Then I see a successful sign in message
      When I return to the site
      Then I should be signed in

    Scenario: Enter the wrong e-mail address
      Given I exist as a user
        And I am not logged in
      When I sign in with a wrong email
      Then I see an invalid login message
        And I should be signed out

    Scenario: Enter the wrong password
      Given I exist as a user
        And I am not logged in
      When I sign in with a wrong password
      Then I see an invalid login message
        And I should be signed out


