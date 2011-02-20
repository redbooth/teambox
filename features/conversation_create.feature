@javascript
Feature: Creating a conversation

  Background: 
    Given a project with user @mislav
    And I am logged in as @mislav

  Scenario: No conversations
    When I go to the conversations page
    Then I should not see any conversations

  Scenario: Valid conversation
    When I go to the conversations page
    And I follow "Create the first conversation in this project"
    Then I should see "New Conversation"
    When I fill in "Title" with "The Internet is a series of tubes"
    And I fill in the comment box with "I just found about this yesterday."
    And I press "Create"
    Then I should see "The Internet is a series of tubes" in the title
    And I should see "I just found about this yesterday."
    And I should see "Mislav Marohnić" in the watchers list
    And I should see "Unwatch" in the watchers list
    When I fill in the comment box with "Really!"
    And I press "Save"
    Then I should see "I just found about this yesterday."
    And I should see "Really!"

  Scenario: Blank conversation
    When I go to the conversations page
    And I follow "Create the first conversation in this project"
    And I fill in "Title" with "I often forget the comment text"
    And I fill in the comment box with ""
    And I press "Create"
    Then I should see "The conversation cannot start with an empty comment."

