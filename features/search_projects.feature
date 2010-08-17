@sphinx @no-txn
Feature: Search comments in projects
  In order to discover what has been said about a subject
  As a Teambox user
  I want to search for keywords

  Background: 
    Given I am logged in as voodoo_prince
    And I am in the project called "Gold Digging"
    And I am in the project called "Space elevator"

  Scenario: Search all projects
    When I go to the projects page
    And I follow "Gold Digging"
    And I fill in "comment_body" with "I found a hunk of gold today in the mine!"
    And I press "Save"
    And I follow "Space elevator"
    And I fill in "comment_body" with "Let's finish this space elevator before Tuesday."
    And I press "Save"
    And I go to the projects page
    
    When the search index is rebuilt
    And I fill in "search" with "the mine"
    And I press "Search"
    Then I should see "1 results found"
    And I should see "I found a hunk of gold today in the mine!"
    But I should not see "finish this space elevator"
