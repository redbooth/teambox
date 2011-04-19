@javascript
Feature: Creating a private task

  Background: 
    Given a project exists with name: "Ruby Rockstars"
    And @mislav exists and is logged in
    And I am in the project called "Ruby Rockstars"
    And the following confirmed users exist
      | login  | email                    | first_name | last_name |
      | pablo  | pablo@teambox.com        | Pablo      | Villalba  |
      | jordi  | jordi@teambox.com        | Jordi      | Romero    |
    And "jordi" is in the project called "Ruby Rockstars"
    And "pablo" is in the project called "Ruby Rockstars"
    And the task list called "Lolbox" belongs to the project called "Ruby Rockstars"

  Scenario: All tasks are private
    Given the task called "Post lolcats" belongs to the task list called "Lolbox"
    When I go to the tasks page
    Then I should not see "Post lolcats"
    When I go to the page of the "Post lolcats" task
    Then I should not see "Post lolcats"

  Scenario: Private task
    When I go to the "Lolbox" task list page of the "Ruby Rockstars" project
    When I follow "+ Add Task"
    And I fill in "Task title" with "Post lolcats"
    And I select "Private"
    And I press "Add Task"
    And I wait for 1 second
    Then I should see "mislav"
    And I should see "Post lolcats" as a task name
    And @pablo should receive no emails
    And @mislav should receive no emails
    When I am logged in as @pablo
    And I go to the page of the "Post lolcats" task
    Then I should not see "Post lolcats"

  Scenario: Managing people in a private task
    Given the private task called "Post lolcats" belongs to the task list called "Lolbox"
    When I go to the page of the "Post lolcats" task
    And I change watchers for the "Post lolcats" task to "@pablo"
    Then I should not see "Post lolcats"
    Given I am logged in as @pablo
    When I go to the page of the "Post lolcats" task
    Then I should see "Post lolcats"
    When I change watchers for the "Post lolcats" task to "@mislav"
    Then I should not see "Post lolcats"

  Scenario: Private tasks are always watched by the creator
    Given the private task called "Post lolcats" belongs to the task list called "Lolbox"
    And the task "Post lolcats" is watched by @pablo
    When I go to the page of the "Post lolcats" task
    And I change watchers for the "Post lolcats" task to ""
    When I go to the page of the "Post lolcats" task
    Then I should see "Post lolcats"
    Given I am logged in as @pablo
    When I go to the page of the "Post lolcats" task
    Then I should not see "Post lolcats"

  Scenario: Making a private task public
    Given the private task called "Post lolcats" belongs to the task list called "Lolbox"
    When I go to the page of the "Post lolcats" task
    And I make the "Post lolcats" task public
    Given I am logged in as @pablo
    When I go to the tasks page
    Then I should see "Post lolcats"
