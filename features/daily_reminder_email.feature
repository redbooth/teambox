@wip
Feature: Daily reminder for tasks email
  In order to have a summary of what I should do that day
  As a user
  I want to receive a list of my tasks for that day
  
  Scenario: Section with tasks for that day
  Given I am the currently mislav
  And I have the daily task reminders turned on
  And I have a task called "Give water to the flowers"
  And the task called "Give water to the flowers" is due today
  Then when the daily reminders for tasks are sent
  Then I should receive an email
  When I open the email with subject "Your tasks for today"
  Then I should "Give water to the flowers" in the email body