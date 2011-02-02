@javascript
Feature: Reorder task within the task list view

  Background:
    Given @mislav exists and is logged in
    And I am in the project called "Teambox"
    And the following task lists with associations exist:
      | name         | project |
      | Bugfixes     | Teambox |
      | Next release | Teambox |
    And I go to the "teambox" tasks page

  Scenario: Reorder task list
    When I follow "Reorder Task Lists"
    And I drag the task list "Bugfixes" above "Next release"
    And I follow "Done reorder"
    And I wait for 1 second
    Then I should see the task list "Bugfixes" before "Next release"
