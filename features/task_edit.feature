@javascript
Feature: Editing a task

  Background:
    Given @charles exists and is logged in
    And I am in the project called "Teambox"
    And the task list called "Bugs" belongs to the project called "Teambox"
    And the following task with associations exist:
      | name          | task_list | project |
      | Fix major bug | Bugs      | Teambox |
    And I go to the "Teambox" tasks page

  Scenario: I change task name from full view
    When I follow "Fix major bug"
    And I wait for 1 second
    And I follow "Full view"
    And I follow "Edit"
    And I fill the name field with "Fix minor bug"
    And I press "Update Task"
    And I wait for 1 second
    Then I should see "Fix minor bug" within the task header
