Feature: See tasks in different, common groupings
  In order to see just the tasks the user needs and quickly
  As a Teambox developer
  I want to give options to see tasks in different groupings

  Background:
    Given a project exists with name: "Market Teambox"
    And a confirmed user exists with login: "balint"
    And "balint" is in the project called "Market Teambox"
    And the following task lists with associations exist:
      | name      | project        |
      | This week | Market Teambox |
      | Later     | Market Teambox |
    And the following tasks with associations exist:
      | name                                   | task_list | project        |
      | Tell my friends                        | This week | Market Teambox |
      | Tell the tech bloggers                 | This week | Market Teambox |
      | Post on Digg and Hacker News           | This week | Market Teambox |
      | Beg Apple to approve of the iPhone app | Later     | Market Teambox |

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
    But I should not see the task called "Tell my friends" in the "This week" task list panel
    When I follow "All Tasks"
    Then I should see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Tell my friends                        |
      | This week        | Tell the tech bloggers                 |
      | This week        | Post on Digg and Hacker News           |
      | Later            | Beg Apple to approve of the iPhone app |
    When I follow "Unarchived Tasks"
    Then I should see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Tell the tech bloggers                 |
      | This week        | Post on Digg and Hacker News           |
      | Later            | Beg Apple to approve of the iPhone app |

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
    But I should not see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Tell the tech bloggers                 |
      | Later            | Beg Apple to approve of the iPhone app |
      | This week        | Tell my friends                        |
    When I follow "Everybody's Tasks"
    Then I should see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Post on Digg and Hacker News           |
      | This week        | Tell the tech bloggers                 |
      | Later            | Beg Apple to approve of the iPhone app |

  Scenario: See archived tasks
    Given I am logged in as "balint"
    And the task called "Tell my friends" is archived
    And the task called "Post on Digg and Hacker News" is archived
    When I go to the list of tasks page of the project called "Market Teambox"
    And I follow "Show 2 Archived Task(s)"
    Then I should see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Tell my friends                        |
      | This week        | Post on Digg and Hacker News           |
    But I should not see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Tell the tech bloggers                 |
      | Later            | Beg Apple to approve of the iPhone app |
    When I follow "Hide Archived Task(s)"
    Then I should see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Tell the tech bloggers                 |
      | Later            | Beg Apple to approve of the iPhone app |
    But I should not see the following tasks:
      | task_list_name   | task_name                              |
      | This week        | Tell my friends                        |
      | This week        | Post on Digg and Hacker News           |

  Scenario: See reopened task
    Given I am logged in as "balint"
    And the task called "Tell my friends" is archived
    When I go to the list of tasks page of the project called "Market Teambox"
    And I follow "All Tasks"
    And I follow "Tell my friends"
    And I follow "Reopen this task"
    And I fill in "comment_body" with "Got some new friends"
    And I press "Comment"
    And I go to the list of tasks page of the project called "Market Teambox"
    Then I should see the task called "Tell my friends" in the "This week" task list panel
