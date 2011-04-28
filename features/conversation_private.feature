@javascript
Feature: Creating a private conversation

  Background:
    Given the following confirmed users exist
      | login  | email                    | first_name | last_name |
      | pablo  | pablo@teambox.com        | Pablo      | Villalba  |
      | jordi  | jordi@teambox.com        | Jordi      | Romero    |
    Given a project with users @mislav, @pablo and @jordi
    And I am logged in as @mislav

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
    And I choose "This element is only visible to people you specify..."
    And I uncheck "Jordi Romero"
    And I uncheck "Pablo Villalba"
    And I press "Create"
    Then I should see "Top Secret" in the title
    And @pablo should receive no emails
    And @mislav should receive no emails
    And @jordi should receive no emails
    When I am logged in as @pablo
    And I go to the page of the "Top Secret" conversation
    Then I should not see "Top Secret"

  @wip
  Scenario: Managing people in a private conversation
    Given @mislav started a private conversation named "Roflcopter"
    Given I am logged in as @pablo
    When I go to the page of the "Roflcopter" conversation
    Then show me the page
    Then I should not see "Roflcopter"
    Given I am logged in as @mislav
    When I go to the page of the "Roflcopter" conversation
    And I fill in the comment box with "Changing private status"
    And I follow "Privacy"
    And I choose "This element is only visible to people you specify..."
    And I check "Pablo Villalba"
    And I uncheck "Jordi Romero"
    And I press "Save"
    Given I am logged in as @pablo
    When I go to the page of the "Roflcopter" conversation
    Then I should see "Roflcopter"
    Given I am logged in as @mislav
    And I go to the page of the "Roflcopter" conversation
    And I fill in the comment box with "Changing private status again"
    When I follow "Privacy"
    And I choose "This element is only visible to people you specify..."
    And I uncheck "Pablo Villalba"
    Then show me the page
    And I press "Save"
    Given I am logged in as @pablo
    When I go to the page of the "Roflcopter" conversation
    Then show me the page
    Then I should not see "Roflcopter"

  Scenario: Private conversations can only be modified by the creator
    Given @mislav started a private conversation named "Roflcopter"
    When I go to the page of the "Roflcopter" conversation
    Then I should see "Privacy"
    And the conversation "Roflcopter" is watched by @pablo
    Given I am logged in as @pablo
    When I go to the page of the "Roflcopter" conversation
    Then I should not see "Privacy"
  
  @wip
  Scenario: Making a private conversation public
    Given @mislav started a private conversation named "Roflcopter"
    When I go to the page of the "Roflcopter" conversation
    And I follow "Privacy"
    And I choose "This element is visible to everybody in this project"
    And I press "Save"
    Given I am logged in as @pablo
    When I go to the conversations page
    Then I should see "Roflcopter"

