@javascript
Feature: Fetch workflow results
  As a registered user
  I want to be able to fetch all my workflow results
  So that I can get to my data easily

    Background:
      Given I am logged in
        And I have a dataset

    Scenario: Get results of finished analysis
      When I start a new workflow analysis
        And I choose the article dates task
        And I confirm the choice
        And I link the dataset
        And I confirm the data
      Then I should be able to start the task
        And I should be able to fetch the workflow results
        And I should be able to view the result data
