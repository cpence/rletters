@javascript @wip
Feature: Solr query searching
  As a very advanced visitor to the website
  I want to be able to search by Solr queries
  So that I can harness the power of Lucene query syntax

    Background:
      Given I am not logged in

    Scenario: Perform a Solr query search
      When I run a Solr query search for 'authors:"Ferkin" OR journal:"Genes"'
      Then I should see a list of articles
        And I should see 457 articles
