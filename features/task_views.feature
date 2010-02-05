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
    Then I should see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Tell the tech bloggers                 |
      | This week        | Post on Digg and Hacker News           |
      | Later            | Beg Apple to approve of the iPhone app |
    And the task called "Tell my friends" in the "This week" task list panel should be hidden
    When I follow "All Tasks"
    Then I should see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Tell my friends                        |
      | This week        | Tell the tech bloggers                 |
      | This week        | Post on Digg and Hacker News           |
      | Later            | Beg Apple to approve of the iPhone app |
    And I should see "Unarchived Tasks"

  @wip
  Scenario: See only my tasks
    Given I am logged in as "balint"
    And the task called "Tell my friends" is assigned to me
    And the task called "Tell my friends" is archived
    And the task called "Post on Digg and Hacker News" is assigned to me
    When I go to the list of tasks page of the project called "Market Teambox"
    And I follow "My 1 Task(s)"
    Then I should see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Post on Digg and Hacker News           |
    And the following tasks should be hidden:
      | task_list_name   | task_name                              |
      | This week        | Tell the tech bloggers                 |
      | Later            | Beg Apple to approve of the iPhone app |
      | This week        | Tell my friends                        |
    And I should see "Everybody's tasks"