@javascript
Feature: Add single document to dataset
  As a registered user
  I want to be able to add an individual document to a dataset
  So that I can have fine control over dataset contents

    Background:
      Given I am logged in
        And I have a dataset with 10 entries

    Scenario: Add a single document to the dataset
      When I search for articles
        And I add the first article to the dataset
      Then the dataset should have 11 entries
