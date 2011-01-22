@javascript @tasks
Feature: Show archived tasks in task lists
  In order to cut down on page load time
  As a Teambox developer
  I want users to see archived tasks in task lists quickly and easily

  Background: 
    Given a project exists with name: "Market Teambox"
    And a confirmed user exists with login: "balint"
    And "balint" is in the project called "Market Teambox"
    And a task list exists with name: "This week"
    And the task list called "This week" belongs to the project called "Market Teambox"
    And the following tasks with associations exist:
      | name                   | task_list | project        |
      | Tell my friends        | This week | Market Teambox |
      | Tell the tech bloggers | This week | Market Teambox |
    And the task called "Tell my friends" is resolved
    And I am logged in as @balint

  Scenario: See archived tasks
    When I go to the "Market Teambox" tasks page
    Then I should see the task called "Tell the tech bloggers" in the "This week" task list
    But I should not see the task called "Tell my friends" in the "This week" task list
    When I follow "Show 1 archived task" in the "This week" task list
    And I wait for .2 seconds
    Then I should see the following tasks:
      | task_list_name | task_name              |
      | This week      | Tell my friends        |
      | This week      | Tell the tech bloggers |

  Scenario: No archived tasks in a task list
    Given a task list exists with name: "Next month"
    And the task list called "Next month" belongs to the project called "Market Teambox"
    And the following tasks with associations exists:
      | name                         | task_list  | project        |
      | Post on Digg and Hacker News | Next month | Market Teambox |
    When I go to the "Market Teambox" tasks page
    Then I should not see a "Show 0 archived tasks" link in the "Next month" task list

