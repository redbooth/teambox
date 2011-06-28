@javascript
Feature: Commenting on a task

  Background:
    Given @mislav exists and is logged in
    And I am in the project called "Teambox"
    And the task list called "This week" belongs to the project called "Teambox"
    And the following task with associations exist:
      | name                         | task_list      | project |
      | Setup Continious integration | This week      | Teambox |
    And I go to the "teambox" tasks page

  Scenario: I change task date by commenting
    When I follow "Setup Continious integration"
    And I wait for 1 second
    And I fill in the comment box with "This should be done in a while"
    And I click on the date selector
    And I select the month of "January" with the date picker
    And I select the year "2010" with the date picker
    And I select the day "25" with the date picker
    And I press "Save"
    And I wait for 2 second
    Then I should see "JAN 25" within the last comment body
    But I fill in the comment box with "I change my mind, should be done ASAP."
    And I click on the date selector
    And I select the month of "January" with the date picker
    And I select the year "2010" with the date picker
    And I select the day "10" with the date picker
    And I press "Save"
    And I wait for 2 second
    Then I should see "JAN 25" and "JAN 10" within the last comment body
