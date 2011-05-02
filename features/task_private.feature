@javascript
Feature: Creating a private task

  Background: 
    Given the following confirmed users exist
      | login  | email                    | first_name | last_name |
      | pablo  | pablo@teambox.com        | Pablo      | Villalba  |
      | jordi  | jordi@teambox.com        | Jordi      | Romero    |
    Given a project with users @mislav, @pablo and @jordi
    And I am logged in as @mislav
    And I have a task list called "Lolbox"

  Scenario: All tasks are private
    Given @pablo created a private task named "Post lolcats" in the task list called "Lolbox"
    When I go to the task lists page
    Then I should not see "Post lolcats"
    When I go to the page of the "Post lolcats" task
    Then I should not see "Post lolcats"

  Scenario: Private task
    When I go to the task lists page
    When I follow "+ Add Task"
    And I fill in "Task title" with "Post lolcats"
    When I follow "Privacy"
    Then the "This element is visible to everybody in this project" checkbox should be checked
    When I choose "This element is only visible to people you specify..."
    And I uncheck "Pablo Villalba"
    And I press "Add Task"
    And I wait for 1 second
    Then I should see "Post lolcats" as a task name
    And @pablo should receive no emails
    And @mislav should receive no emails
    When I am logged in as @pablo
    And I go to the page of the "Post lolcats" task
    Then I should not see "Post lolcats"

  Scenario: Managing people in a private task
    Given @mislav created a private task named "Post lolcats" in the task list called "Lolbox"
    When I go to the page of the "Post lolcats" task
    And I fill in the comment box with "Just updating!"
    When I follow "Privacy"
    Then the "This element is only visible to people you specify..." checkbox should be checked
    When I choose "This element is only visible to people you specify..."
    And I uncheck "Jordi Romero"
    And I check "Pablo Villalba"
    And I press "Save"
    Given I am logged in as @jordi
    Then I should not see "Post lolcats"
    Given I am logged in as @pablo
    When I go to the page of the "Post lolcats" task
    Then I should see "Post lolcats"
    And I should not see "Privacy"
    Given I am logged in as @mislav
    When I go to the page of the "Post lolcats" task
    And I fill in the comment box with "Just updating again!"
    When I follow "Privacy"
    Then the "This element is only visible to people you specify..." checkbox should be checked
    When I choose "This element is only visible to people you specify..."
    And I uncheck "Pablo Villalba"
    And I press "Save"
    Given I am logged in as @pablo
    When I go to the page of the "Post lolcats" task
    Then I should not see "Post lolcats"

  Scenario: Private tasks can only be modified by the creator
    Given @mislav created a private task named "Post lolcats" in the task list called "Lolbox"
    And the task "Post lolcats" is watched by @pablo
    When I go to the page of the "Post lolcats" task
    Then I should see "Privacy"
    Given I am logged in as @pablo
    When I go to the page of the "Post lolcats" task
    Then I should not see "Privacy"

  Scenario: Making a private task public
    Given @mislav created a private task named "Post lolcats" in the task list called "Lolbox"
    When I go to the page of the "Post lolcats" task
    And I fill in the comment box with "Just updating!"
    When I follow "Privacy"
    Then the "This element is only visible to people you specify..." checkbox should be checked
    When I choose "This element is visible to everybody in this project"
    And I press "Save"
    When I go to the task lists page
    Given I am logged in as @pablo
    When I go to the task lists page
    Then I should see "Post lolcats"

