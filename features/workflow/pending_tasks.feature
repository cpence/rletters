@javascript
Feature: View pending task status
  As a registered user
  I want to be able to see pending task status
  So that I know how my analyses are progressing

    Background:
      Given I am logged in
        And I have a dataset
        And I have a pending analysis task

    Scenario: View status of pending task
      When I visit the status page
      Then I should see the status of my task
