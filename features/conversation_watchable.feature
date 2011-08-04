@javascript
Feature: Watchers for conversations

  Background:
    Given the following confirmed users exist
      | login  | email                    | first_name | last_name |
      | pablo  | pablo@teambox.com        | Pablo      | Villalba  |
      | enric  | enric@teambox.com        | Enric      | Lluelles  |
      | james  | james@teambox.com        | James      | Urquhart  |
    Given a project with users @mislav, @enric, @pablo and @james
    And I am logged in as @mislav
    And no emails have been sent

  Scenario: Adding watchers to an untitled conversation
    Given I go to the projects page
    When I fill in the comment box with "Hey, guys..."
    And I wait for 1 second
    When I follow "Watchers" 
    Then I should see "All users"
    And I should see "Andrew Wiggin"
    When I follow "All users"
    And I press "Save"
    And I wait for 2 second
    Then @enric, @pablo and @james should receive 1 emails

  Scenario: New conversation watchers
    When I go to the new conversation page
    And I fill in "Title" with "Talk!"
    And I fill in the comment box with "We need to discuss!"
    And I uncheck "James Urquhart"
    And I press "Create"
    Then @enric and @pablo should be watching the conversation "Talk!"
    And @james should not be watching the conversation "Talk!"
    When I fill in the comment box with "Rockets!"
    And I press "Save"
    And I wait for 1 second
    Then @enric and @pablo should receive 2 emails
    And @james should receive 0 emails

  Scenario: New conversation watchers but with user who watches all conversations in given project
    Given I am logged in as @pablo
    When I go to the account notifications page
    And I check the conversation column for the first project setting
    And I press "Update account"
    Then the checkbox on the conversation column for the first project setting should be checked
    When I am logged in as @mislav
    And I go to the new conversation page
    And I fill in "Title" with "Talk!"
    And I fill in the comment box with "We need to discuss!"
    And I uncheck "James Urquhart"
    And I press "Create"
    Then @enric and @pablo should be watching the conversation "Talk!"
    And @james should not be watching the conversation "Talk!"
    When I go to the new conversation page
    And I fill in "Title" with "Talk again!"
    And I fill in the comment box with "We need to discuss again!"
    And I uncheck "Pablo Villalba"
    And I press "Create"
    Then @enric and @pablo and @james should be watching the conversation "Talk again!"

  Scenario: Existing conversation with watchers
    Given I started a conversation named "Politics"
    And the conversation "Politics" is watched by @pablo and @james
    When I go to the conversations page
    And I follow "Politics"
    And I fill in the comment box with "Senators!"
    And I press "Save"
    And I wait for 1 second
    And I fill in the comment box with "Rockets!"
    And I press "Save"
    And I wait for 1 second
    Then @enric should receive no emails
    And @pablo and @james should receive 2 emails

  Scenario: User leaves project
    Given I started a conversation named "Politics"
    And the conversation "Politics" is watched by @enric, @pablo and @james
    And @pablo left the project
    When I go to the conversations page
    And I follow "Politics"
    And I fill in the comment box with "Celebrities!"
    And I press "Save"
    And I wait for 1 second
    And I fill in the comment box with "Controversy!"
    And I press "Save"
    And I wait for 1 second
    Then @pablo should receive no emails
    And @enric and @james should receive 2 emails
