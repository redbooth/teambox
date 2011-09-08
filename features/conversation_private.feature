@javascript
Feature: Creating a private conversation

  Background:
    Given the following confirmed users exist
      | login  | email                    | first_name | last_name |
      | pablo  | pablo@teambox.com        | Pablo      | Villalba  |
      | jordi  | jordi@teambox.com        | Jordi      | Romero    |
      | enric  | enric@teambox.com        | Enric      | Lluelles  |
    And a project exists with name: "Ruby Rockstars"
    And @mislav exists and is logged in
    And I am in the project called "Ruby Rockstars"
    And "mislav" is an administrator in the project
    And @pablo, @jordi and @enric is currently in the project "Ruby Rockstars"

  Scenario: All conversations are private
    Given @pablo started a private conversation named "Roflcopter"
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
    When I follow "Privacy"
    Then the "This element is visible to everybody in this project" checkbox should be checked
    When I choose "This element is only visible to people you specify..."
    And I check "Jordi Romero"
    And I uncheck "Pablo Villalba"
    And I press "Create"
    Then I should see "Top Secret" in the title
    Then @pablo should not be watching the conversation "Top Secret"
    Then @jordi should be watching the conversation "Top Secret"
    Then @mislav should be watching the conversation "Top Secret"
    When I am logged in as @pablo
    And I go to the page of the "Top Secret" conversation
    Then I should not see "Top Secret"

  Scenario: Managing people in a private conversation
    Given @mislav started a private conversation named "Roflcopter"
    Given I am logged in as @pablo
    When I go to the page of the "Roflcopter" conversation
    Then I should not see "Roflcopter"
    Given I am logged in as @mislav
    When I go to the page of the "Roflcopter" conversation
    And I fill in the comment box with "Changing private status"
    And I follow "Privacy"
    Then the "This element is only visible to people you specify..." checkbox should be checked
    When I choose "This element is only visible to people you specify..."
    And I check "Pablo Villalba"
    And I uncheck "Jordi Romero"
    And I press "Save"
    Given I am logged in as @pablo
    When I go to the page of the "Roflcopter" conversation
    Then I should see "Roflcopter"
    When I follow "Privacy"
    Then I should see "This element is only visible to the following people..."
    Given I am logged in as @mislav
    And I go to the page of the "Roflcopter" conversation
    And I fill in the comment box with "Changing private status again"
    When I follow "Privacy"
    And I choose "This element is only visible to people you specify..."
    And I uncheck "Pablo Villalba"
    And I press "Save"
    Given I am logged in as @pablo
    When I go to the page of the "Roflcopter" conversation
    Then I should not see "Roflcopter"

  Scenario: Private conversations can only be modified by the creator
    Given @mislav started a private conversation named "Roflcopter"
    And the conversation "Roflcopter" is watched by @pablo
    When I go to the page of the "Roflcopter" conversation
    And I follow "Privacy"
    Then I should see "This element is only visible to people you specify..."
    Given I am logged in as @pablo
    When I go to the page of the "Roflcopter" conversation
    And I follow "Privacy"
    Then I should see "This element is only visible to the following people..."

  Scenario: Mislav is forever alone
    Given Only @mislav is in the project
    And @mislav started a private conversation named "Roflcopter"
    When I go to the page of the "Roflcopter" conversation
    And I follow "Privacy"
    Then I should see "This element is only visible to you"
  
  Scenario: Making a private conversation public
    Given @mislav started a private conversation named "Roflcopter"
    And the conversation "Roflcopter" is watched by @jordi
    When I go to the page of the "Roflcopter" conversation
    And I fill in the comment box with "Making this public"
    And I follow "Privacy"
    Then the "This element is only visible to people you specify..." checkbox should be checked
    When I choose "This element is visible to everybody in this project"
    And I press "Save"
    Given I am logged in as @pablo
    When I go to the conversations page
    Then I should see "Roflcopter"

  Scenario: Private conversations are private
    Given @enric started a private conversation named "Let's fire Jordi"
    And the search index is reindexed
    When I go to the profile of "enric"
    Then I should see "Enric Lluelles"
    And  I should not see "fire Jordi"
    When I search for "fire"
    And I wait for 1 second
    Then I should not see "fire Jordi"
    When I go to the project page
    Then I should not see "fire Jordi"

  Scenario: Files in private conversations are private
    Given @jordi started a private conversation named "Look at this private document @mislav can't see" in the "Ruby Rockstars" project with an attached file
    And @mislav started a private conversation named "Look at this other private document" in the "Ruby Rockstars" project with an attached file
    And I go to the conversations page
    Then I should see "Look at this other private document"
    And I go to the uploads page
    Then I should see "Private document at Look at this other private document"
    Then I should not see "Private document at Look at this private document"

