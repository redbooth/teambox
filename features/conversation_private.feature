@javascript @wip
Feature: Creating a private conversation

  Background: 
    Given a project with user @mislav
    And I am logged in as @mislav
    And the following confirmed users exist
      | login  | email                    | first_name | last_name |
      | pablo  | pablo@teambox.com        | Pablo      | Villalba  |
      | jordi  | jordi@teambox.com        | Jordi      | Romero    |
    And "jordi" is in the project called "Ruby Rockstars"
    And "pablo" is in the project called "Ruby Rockstars"

  Scenario: All conversations are private
    Given @pablo started a private conversation called "Roflcopter"
    When I go to the conversations page
    Then I should not see any conversations
    When I go to the page of the "Roflcopter" conversation
    Then I should not see "Roflcopter"

  Scenario: Private conversation
    When I go to the conversations page
    And I follow "Create the first conversation in this project"
    Then I should see "New Conversation"
    When I fill in "Title" with "Top Secret"
    And I fill in the comment box with "@all @pablo we are in some serious trouble here!"
    And I press "Create"
    Then I should see "Top Secret" in the title
    And @pablo should receive no emails
    And @mislav should receive no emails
    And @jordi should receive no emails
    When I am logged in as @pablo
    And I go to the page of the "Top Secret" conversation
    Then I should not see "Top Secret"

  Scenario: Managing people in a private conversation
    Given @mislav started a private conversation named "Roflcopter"
    When I go to the page of the "Roflcopter" conversation
    And I change watchers for the "Rolfcopter" conversation to "@pablo"
    Then I should not see "Roflcopter"
    Given I am logged in as @pablo
    When I go to the page of the "Roflcopter" conversation
    Then I should see "Roflcopter"
    When I change watchers for the "Rolfcopter" conversation to "@mislav"
    Then I should not see "Roflcopter"

  Scenario: Private conversations are always watched by the creator
    Given @mislav started a private conversation named "Roflcopter"
    And the conversation "Roflcopter" is watched by @pablo
    When I go to the page of the "Roflcopter" conversation
    And I change watchers for the "Rolfcopter" conversation to ""
    When I go to the page of the "Roflcopter" conversation
    Then I should see "Roflcopter"
    Given I am logged in as @pablo
    When I go to the page of the "Roflcopter" conversation
    Then I should not see "Roflcopter"
  
  Scenario: Making a private conversation public
    Given @mislav started a private conversation named "Roflcopter"
    When I go to the page of the "Roflcopter" conversation
    And I make the "Roflcopter" conversation public
    Given I am logged in as @pablo
    When I go to the conversations page
    Then I should see "Roflcopter"

