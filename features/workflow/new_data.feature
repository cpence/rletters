@javascript @modal
Feature: Run an analysis on new data
  As a registered user
  I want to be able to use the workflow tools to analyze new datasets
  So that I can perform the entire analysis within the workflow

    Background:
      Given I am logged in

    Scenario: Run a workflow analysis on new data
      When I start a new workflow analysis
        And I choose the article dates task
        And I confirm the choice
        And I choose to create a new dataset
        And I search for articles
        And I create a dataset from the current search
        And I confirm the data
      Then I should be able to start the task
        And I should be able to fetch the workflow results
