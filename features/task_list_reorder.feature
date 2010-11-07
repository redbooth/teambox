@javascript
Feature: Reorder task within the task list view

  Background:
    Given I am logged in as mislav
    And I am in the project called "Teambox"
    And the following task lists with associations exist:
      | name         | project |
      | Next release | Teambox |
      | Bugfixes     | Teambox |
    And I go to the "teambox" tasks page

  Scenario: Reorder task list
    When I follow "Reorder Task Lists"
    And I drag "Bugfixes" above "Next release"
    And I follow "Done reorder"
    And I wait for 1 second
    Then I should see the task list "Bugfixes" before "Next release"