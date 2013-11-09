@javascript
Feature: Links to local libraries
  As a registered user of the website
  I want to link my account to my local library
  So that I can download documents via its web service

    Background:
      Given I am logged in

    Scenario: Automatically adding a link to a library
      When I visit my account page
        And I add a library automatically
      Then I should see the library in the list
        And I should be able to fetch a document using the library

    Scenario: Manually adding a link to a library
      When I visit my account page
        And I manually add the library "Harvard" with URL "http://library.harvard.edu/?"
      Then I should see the library in the list
        And I should be able to fetch a document using the library
