@javascript
Feature: Create dataset from search
  As a registered user
  I want to be able to save the results of a search as a dataset
  So that I can run an analysis on those documents

    Background:
      Given I am logged in

    Scenario: Save the results of a search as a dataset
      When I search for articles
        And I create a dataset from the current search
      Then I should see the dataset in the list of datasets
        And I should be able to view the dataset's properties
