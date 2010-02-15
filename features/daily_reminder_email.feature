Feature: Daily reminder for tasks email
  In order to have a summary of what I should do that day
  As a user
  I want to receive a list of my tasks for that day

  Scenario: User with a late task due assigned to him
    Given I am currently "mislav"
    And I have the daily task reminders turned on
    And there is a task called "Give water to the flowers"
    And the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" was due 3 days ago
    When the daily reminders for tasks are sent
    Then I should receive an email
    When I open the email with subject "Daily task reminder"
    Then I should see "Late tasks" in the email body
    And I should see "Give water to the flowers" in the email body

  Scenario: User with a task due today assigned to him
    Given I am currently "mislav"
    And I have the daily task reminders turned on
    And there is a task called "Give water to the flowers"
    And the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due today
    When the daily reminders for tasks are sent
    Then I should receive an email
    When I open the email with subject "Daily task reminder"
    Then I should see "Tasks for today" in the email body
    Then I should see "Give water to the flowers" in the email body

  Scenario: User with the task reminders turned off
    Given I am currently "mislav"
    And I have the daily task reminders turned off
    And there is a task called "Give water to the flowers"
    And the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due today
    When the daily reminders for tasks are sent
    Then I should receive no emails

  Scenario: User with a task due tomorrow assigned to him
    Given I am currently "mislav"
    And I have the daily task reminders turned on
    And there is a task called "Give water to the flowers"
    And the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due tomorrow
    When the daily reminders for tasks are sent
    When I open the email with subject "Daily task reminder"
    Then I should see "Tasks for tomorrow" in the email body
    Then I should see "Give water to the flowers" in the email body

  @wip
  Scenario: User with a task due some time in the next two weeks
    Given I am currently "mislav"
    And I have the daily task reminders turned on
    And there is a task called "Give water to the flowers"
    And the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due in 4 days
    When the daily reminders for tasks are sent
    When I open the email with subject "Daily task reminder"
    Then I should see "Tasks for next two weeks" in the email body
    Then I should see "Give water to the flowers" in the email body
    But I should not see "Tasks for tomorrow" in the email body

  Scenario: User in a project that has a task due today but not assigned that task
    Given I am currently "mislav"
    And there is a user called "balint"
    And I have the daily task reminders turned on
    And there is a task called "Give water to the flowers"
    And the task called "Give water to the flowers" is assigned to "balint"
    And the task called "Give water to the flowers" is due today
    When the daily reminders for tasks are sent
    Then I should receive no emails

  Scenario: User with no tasks
    Given I am currently "mislav"
    And I have the daily task reminders turned on
    But I have no tasks assigned to me
    When the daily reminders for tasks are sent
    Then I should receive no emails
