@tasks
Feature: List tasks in project broken down by task list

  Background: 
    Given @mislav exists and is logged in
    And I am in the project called "teambox"

  Scenario: Task list index
    Given the task list called "urgent" belongs to the project called "teambox"
    And the task called "fix big problem" belongs to the task list called "urgent"
    And the task called "fix big problem" is open
    And the task called "daily reminder email" belongs to the task list called "urgent"
    And the task called "daily reminder email" is resolved
    When I go to the "teambox" tasks page
    Then I should see "fix big problem"
    But I should not see "daily reminder email"

