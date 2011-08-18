@javascript
Feature: Expanded and collapsed mode for activity threads

  Background: 
    Given a project with user @mislav
    And I am logged in as @mislav
    And there is a project with a conversation

  Scenario: I can expand and collapse threads globally
    When I go to the projects page 
    Then I should see "Conversation title"
    And I should see "Conversation body"

    When I follow "View threads expanded"
    Then I should see "Conversation title"
    And I should see "Conversation body"

    When I follow "View threads collapsed"
    Then I should see "Conversation title"
    But I should not see "Conversation body"

  Scenario: I set expanded threads and it persists as a setting
    Given I set my preference to expanded threads
    When I go to the projects page
    Then I should see "Conversation title"
    But I should see "Conversation body"

  Scenario: I set expanded threads and it persists as a setting
    Given I set my preference to collapsed threads
    When I go to the projects page
    Then I should see "Conversation title"
    But I should not see "Conversation body"
