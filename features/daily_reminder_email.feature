@wip
Feature: Daily reminder for tasks email
  In order to have a summary of what I should do that day
  As a user
  I want to receive a list of my tasks for that day
  
  Scenario: User with a task due today assigned to him should receive an email
    Given I am currently "mislav"
    And I have the daily task reminders turned on
    And there is a task called "Give water to the flowers"
    And the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due today
    When the daily reminders for tasks are sent
    Then I should receive an email
    When I open the email with subject "Your tasks for today"
    Then I should see "Give water to the flowers" in the email body
      
  Scenario: User with the task reminders turned off should not receive an email
    Given I am currently "mislav"
    And I have the daily task reminders turned off
    And there is a task called "Give water to the flowers"
    And the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due today
    When the daily reminders for tasks are sent
    Then I should receive no emails
  
  Scenario: User with a task due some time in the future (not today) assigned to him should not receive an email
    Given I am currently "mislav"
    And I have the daily task reminders turned on
    And there is a task called "Give water to the flowers"
    And the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due tomorrow
    When the daily reminders for tasks are sent
    Then I should receive no emails

  Scenario: User in a project that has a task due today but not assigned that task should not receive an email
    Given I am currently "mislav"
    And there is a user called "balint"
    And I have the daily task reminders turned on
    And there is a task called "Give water to the flowers"
    And the task called "Give water to the flowers" is assigned to "balint"
    And the task called "Give water to the flowers" is due today
    When the daily reminders for tasks are sent
    Then I should receive no emails

  Scenario: User with no tasks should not receive an email
    Given I am currently "mislav"
    And I have the daily task reminders turned on
    But I have no tasks assigned to me
    When the daily reminders for tasks are sent
    Then I should receive no emails
  