@javascript
Feature: Run an analysis on existing data
  As a registered user
  I want to be able to use the workflow tools to analyze existing data
  So that I can quickly execute analyses

    Background:
      Given I am logged in
        And I have a dataset

    Scenario: Run a workflow analysis on existing data
      When I start a new workflow analysis
        And I choose the plot dates task
        And I confirm the choice
        And I link the dataset
        And I confirm the data
      Then I should be able to start the task
        And I should be able to fetch the workflow results

    Scenario: Run a workflow analysis on two datasets
      Given I have another dataset
      When I start a new workflow analysis
        And I choose the Craig Zeta task
        And I confirm the choice
        And I link the dataset
        And I link the other dataset
        And I confirm the data
      Then I should be able to start the task
        And I should be able to fetch the workflow results
