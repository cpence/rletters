@javascript
Feature: Delete a dataset
  As a registered user
  I want to be able to delete a dataset
  So that I can clean up when I'm done with analyses

    Background:
      Given I am logged in
        And I have a dataset

    Scenario: Delete a dataset
      When I view the list of datasets
        And I delete the dataset
      Then I should see no datasets in the list of datasets
