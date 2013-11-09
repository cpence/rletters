@javascript
Feature: Show information about dataset
  As a registered user with datasets
  I want to be able to see information about my datasets
  So that I can know what I've saved

    Background:
      Given I am logged in
        And I have a dataset

    Scenario: Display basic dataset information
      When I visit the page for the dataset
      Then I should see the number of articles
        And I should see the list of analysis tasks
        And I should see links for starting new analysis tasks

    Scenario: Display pending analysis tasks
      Given I have a pending analysis task
      When I visit the page for the dataset
      Then I should see an alert for the pending task

    Scenario: Display failed analysis tasks
      Given I have a failed analysis task
      When I visit the page for the dataset
      Then I should see an alert for the failed task

    Scenario: Clear failed analysis tasks
      Given I have a failed analysis task
      When I clear the failed task
        And I visit the page for the dataset
      Then I should see no alert for the failed task

    Scenario: Display finished analysis tasks
      Given I complete an analysis task for the dataset
      When I visit the page for the dataset
      Then I should be able to view the results of the task
        And I should be able to delete the task
