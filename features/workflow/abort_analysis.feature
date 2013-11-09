@javascript
Feature: Abort workflow analysis
  As a registered user
  I want to be able abort the current workflow
  So that I can start a new one

    Background:
      Given I am logged in
        And I have a dataset

    Scenario: Abort a workflow analysis
      When I start a new workflow analysis
        And I choose the plot dates task
        And I confirm the choice
        And I link the dataset
        And I abort the workflow
      Then I should no longer be building a workflow
