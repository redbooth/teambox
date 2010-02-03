@wip
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
    And a task exists with name: "Tell my friends"
    And a task exists with name: "Tell the tech bloggers"
    And the task called "Tell my friends" belongs to the task list called "This week"
    And the task called "Tell the tech bloggers" belongs to the task list called "This week"
    And the task called "Tell my friends" belongs to the project called "Market Teambox"
    And the task called "Tell the tech bloggers" belongs to the project called "Market Teambox"

  Scenario: See archived tasks
    Given the task called "Tell my friends" is archived
    And I am logged in as "balint"
    When I go to the list of tasks page of the project called "Market Teambox"
    Then I should see the task called "Tell the tech bloggers" in the "This week" task list panel
    And the task called "Tell my friends" in the "This week" task list panel should be hidden
    When I follow "Show archived tasks" in the "This week" task list panel
    Then I should see the task called "Tell the tech bloggers" in the "This week" task list panel
    And I should see the task called "Tell my friends" in the "This week" task list panel