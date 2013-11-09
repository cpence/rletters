@javascript
Feature: Manually running analysis tasks
  As an advanced user with datasets
  I want to be able to manually run analysis tasks
  So that I can have precise control over task settings

    Background:
      Given I am logged in
        And I have a dataset

    Scenario: Running a single-dataset analysis task
      When I visit the page for the dataset
        And I start an analysis task for the dataset
      Then I should be able to configure parameters for the task
        And I should be able to start the task
        And I should be able to view the results of the task

    Scenario: Running a multiple-dataset analysis task
      Given I have another dataset
      When I visit the page for the dataset
        And I start a multi-dataset analysis task for the dataset
      Then I should be able to select the second dataset for the task
        And I should be able to start the task
        And I should be able to view the results of the task
