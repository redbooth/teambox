@javascript
Feature: Unsubscribe conversation from the watcher index

  Background: 
    Given a project with user @mislav
    And I am logged in as @mislav
    And I started a conversation named "Refactor"
    When I go to my watch list

  Scenario: I unsubscribe from a conversation
    When I should see "Refactor"
    And I click remove
    And I should not see "Refactor"
