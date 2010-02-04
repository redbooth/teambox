@wip
Feature: See tasks in different, common groupings
  In order to see just the tasks the user needs and quickly
  As a Teambox developer
  I want to give options to see tasks in different groupings

  Background:
    Given a project exists with name: "Market Teambox"
    And a confirmed user exists with login: "balint"
    And "balint" is in the project called "Market Teambox"
    And a task list exists with name: "This week"
    And the task list called "This week" belongs to the project called "Market Teambox"
    And a task list exists with name: "Later"
    And the task list called "Later" belongs to the project called "Market Teambox"
    And a task exists with name: "Tell my friends"
    And a task exists with name: "Tell the tech bloggers"
    And a task exists with name: "Post on Digg and Hacker News"
    And a task exists with name: "Beg Apple to approve of the iPhone app"
    And the task called "Tell my friends" belongs to the task list called "This week"
    And the task called "Tell the tech bloggers" belongs to the task list called "This week"
    And the task called "Post on Digg and Hacker News" belongs to the task list called "This week"
    And the task called "Beg Apple to approve of the iPhone app" belongs to the task list called "Later"
    And the task called "Tell my friends" belongs to the project called "Market Teambox"
    And the task called "Tell the tech bloggers" belongs to the project called "Market Teambox"
    And the task called "Post on Digg and Hacker News" belongs to the project called "Market Teambox"
    And the task called "Beg Apple to approve of the iPhone app" belongs to the project called "Market Teambox"

  Scenario: See all the tasks
    Given the task called "Tell my friends" is resolved
    And the task called "Tell my friends" is archived
    And the task called "Tell the tech bloggers" is open
    And the task called "Post on Digg and Hacker News" is hold
    And the task called "Beg Apple to approve of the iPhone app" is rejected
    And I am logged in as "balint"
    When I go to the list of tasks page of the project called "Market Teambox"
    Then I should see the task called "Tell the tech bloggers" in the "This week" task list panel
    And the task called "Tell my friends" in the "This week" task list panel should be hidden
    And I should see the task called "Post on Digg and Hacker News" in the "This week" task list panel
    And I should see the task called "Beg Apple to approve of the iPhone app" in the "Later" task list panel
    When I follow "All Tasks"
    Then I should see the task called "Tell the tech bloggers" in the "This week" task list panel
    And I should see the task called "Tell my friends" in the "This week" task list panel
    And I should see the task called "Post on Digg and Hacker News" in the "This week" task list panel
    And I should see the task called "Beg Apple to approve of the iPhone app" in the "Later" task list panel
    And I should see "Unarchived Tasks"
