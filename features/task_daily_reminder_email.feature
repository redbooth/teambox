Feature: Daily reminder for tasks email
  In order to have a reminder of what I should do that day
  As a user
  I want to receive a list of my due tasks at morning each workday

  Background: 
    Given a confirmed user exists with login: "mislav", time_zone: "Amsterdam"
    And a project exists with name: "Aquaculture"
    And the task list called "ASAP" belongs to the project called "Aquaculture"
    And the following task with associations exist:
      | name                      | task_list | project     |
      | Give water to the flowers | ASAP      | Aquaculture |
    And I am currently "mislav"
    And I have the daily task reminders turned on
    And the time is "Fri Jul 30 6:19:54 UTC 2010"
    And the email reminders are to be sent at 08

  Scenario: Only users in the proper timezone get the current batch of reminders
    Given a confirmed user exists with login: "disco_stu", time_zone: "UTC", email: "disco_stu@loves.yu"
    And the following task with associations exist:
      | name                      | task_list | project     |
      | Find cure for disco fever | ASAP      | Aquaculture |
    And I am currently "disco_stu"
    And I have the daily task reminders turned on
    And the task called "Find cure for disco fever" is assigned to me
    And the task called "Find cure for disco fever" is due today
    And the task called "Give water to the flowers" is assigned to "mislav"
    And the task called "Give water to the flowers" is due today
    And I am currently "mislav"
    When the daily task reminders go out
    Then I should receive an email
    But "disco_stu@loves.yu" should receive no emails

  Scenario: User with a late task assigned to him
    Given the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" was due 3 days ago
    When the daily task reminders go out
    Then I should receive an email
    When I open the email with subject "Daily task reminder"
    Then I should see "Late tasks" in the email body
    And I should see "Give water to the flowers" in the email body

  Scenario: User with a task due today assigned to him
    Given the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due today
    When the daily task reminders go out
    Then I should receive an email
    When I open the email with subject "Daily task reminder"
    Then I should see "Tasks for today" in the email body
    And I should see "Give water to the flowers" in the email body
    When I follow "Give water to the flowers" in the email
    And I fill in "Email or Username" with "mislav"
    And I fill in "Password" with "dragons"
    And I press "Log in"
    Then I should see "Aquaculture"
    Then I should see "Give water to the flowers"

  Scenario: Tasks link to their parent project, for clarity
    Given the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due today
    When the daily task reminders go out
    Then I should receive an email
    When I open the email with subject "Daily task reminder"
    And I follow "Aquaculture" in the email
    And I fill in "Email or Username" with "mislav"
    And I fill in "Password" with "dragons"
    And I press "Log in"
    Then I should see "Aquaculture"

  Scenario Outline: User with a task due doesn't receive reminders on weekends
    Given today is <day>
    And the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due in 3 days
    When the daily task reminders go out
    Then I should receive no emails

    Examples: 
      | day      |
      | Saturday |
      | Sunday   |

  Scenario: User with the task reminders turned off
    Given I have the daily task reminders turned off
    And the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due today
    When the daily task reminders go out
    Then I should receive no emails

  Scenario: User with a task due tomorrow assigned to him
    Given the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due tomorrow
    When the daily task reminders go out
    When I open the email with subject "Daily task reminder"
    Then I should see "Tasks for tomorrow" in the email body
    And I should see "Give water to the flowers" in the email body

  Scenario: User with a task due some time in the next two weeks
    Given the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due in 4 days
    When the daily task reminders go out
    When I open the email with subject "Daily task reminder"
    Then I should see "Tasks for next two weeks" in the email body
    And I should see "Give water to the flowers" in the email body
    But I should not see "Tasks for tomorrow" in the email body

  Scenario: User assigned a task without a due date
    Given the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" does not have a due date
    When the daily task reminders go out
    Then I should receive no emails

  Scenario: User assigned a story due today and another one without a due date
    Given the following task with associations exist:
      | name            | task_list | project     |
      | Flood the trees | ASAP      | Aquaculture |
    And the task called "Give water to the flowers" is assigned to me
    And the task called "Flood the trees" is assigned to me
    And the task called "Give water to the flowers" is due today
    And the task called "Flood the trees" does not have a due date
    When the daily task reminders go out
    Then I should receive an email
    When I open the email with subject "Daily task reminder"
    Then I should see "Tasks for today" in the email body
    And I should see "Give water to the flowers" in the email body
    But I should not see "Tasks without a due date" in the email body
    And I should not see "Flood the trees" in the email body

  Scenario: User in a project that has a task due today but not assigned that task
    Given a user exists with login: "balint"
    And the task called "Give water to the flowers" is assigned to "balint"
    And the task called "Give water to the flowers" is due today
    When the daily task reminders go out
    Then I should receive no emails

  Scenario: User with no tasks
    Given I have no tasks assigned to me
    When the daily task reminders go out
    Then I should receive no emails

  Scenario: User should receive reminder in their locale
    Given the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due tomorrow
    Then I change my locale to français
    When the daily task reminders go out
    Then I open the email
    And I should see "Ceci est un courriel de rappel pour vos tâches sur Teambox" in the email body
