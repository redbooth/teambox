@javascript
Feature: Showing tasks

  Background:
    Given @charles exists and is logged in
    And I am in the project called "Teambox"
    And the task list called "Bugs" belongs to the project called "Teambox"
    And the following task with associations exist:
      | name          | task_list | project |
      | Fix major bug | Bugs      | Teambox |
    And the task called "Fix major bug" is due today
    And the task called "Fax Major" is assigned to "charles"

  Scenario: I timewarp to the future and see my task is now late
    Given @charles has his time zone set to Madrid
    And utc time is now 1 hour and a bit before midnight
    And I go to the "Teambox" tasks page
    Then I should see "1 days late"
    And time is flowing normally again
