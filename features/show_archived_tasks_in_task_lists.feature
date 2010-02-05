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
      | name                                   | task_list | project        |
      | Tell my friends                        | This week | Market Teambox |
      | Tell the tech bloggers                 | This week | Market Teambox |
    And the task called "Tell my friends" is archived
    And I am logged in as "balint"

  Scenario: See archived tasks
    When I go to the list of tasks page of the project called "Market Teambox"
    Then I should see the task called "Tell the tech bloggers" in the "This week" task list panel
    But I should not see the task called "Tell my friends" in the "This week" task list panel
    When I follow "Show archived tasks" in the "This week" task list panel
    Then I should see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Tell my friends                        |
      | This week        | Tell the tech bloggers                 |

  Scenario: Task panel's "See archived tasks" clicked after global "All tasks"
    When I go to the list of tasks page of the project called "Market Teambox"
    And I follow "All Tasks"
    And I follow "Show archived tasks"
    Then I should see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Tell my friends                        |
      | This week        | Tell the tech bloggers                 |
    When I follow "Hide archived tasks" in the "This week" task list panel
    Then I should see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Tell the tech bloggers                 |
    But I should not see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Tell my friends                        |

  Scenario: "All tasks" clicked after task panel's "See archived tasks"
    When I go to the list of tasks page of the project called "Market Teambox"
    And I follow "Show archived tasks"
    And I follow "All Tasks"
    Then I should see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Tell my friends                        |
      | This week        | Tell the tech bloggers                 |
    When I follow "Hide archived tasks"
    Then I should see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Tell the tech bloggers                 |
    But I should not see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Tell my friends                        |
