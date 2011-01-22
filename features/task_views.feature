@javascript @tasks
Feature: See tasks in different, common groupings
  In order to see just the tasks the user needs and quickly
  As a Teambox developer
  I want to give options to see tasks in different groupings

  Background: 
    Given a project exists with name: "Market Teambox"
    And a confirmed user exists with login: "balint"
    And I am logged in as @balint
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
    And the task called "Tell my friends" is resolved
    And the task called "Tell the tech bloggers" is open
    And the task called "Post on Digg and Hacker News" is hold
    And the task called "Beg Apple to approve of the iPhone app" is rejected
    When I go to the "Market Teambox" tasks page
    Then I should see the following tasks:
      | task_list_name | task_name                    |
      | This week      | Tell the tech bloggers       |
      | This week      | Post on Digg and Hacker News |
    But I should not see the task called "Tell my friends" in the "This week" task list
    And I should not see the task called "Beg Apple to approve of the iPhone app" in the "Later" task list

  Scenario: See only my tasks
    Given the task called "Tell my friends" is assigned to me
    And the task called "Tell my friends" is resolved
    And the task called "Post on Digg and Hacker News" is assigned to me
    And the task called "Post on Digg and Hacker News" is open
    When I go to the "Market Teambox" tasks page
    And I select "My tasks (1)" from "filter_assigned"
    And I wait for .2 seconds
    Then I should see the following tasks:
      | task_list_name | task_name                    |
      | This week      | Post on Digg and Hacker News |
    But I should not see the following tasks:
      | task_list_name | task_name                              |
      | This week      | Tell the tech bloggers                 |
      | Later          | Beg Apple to approve of the iPhone app |
      | This week      | Tell my friends                        |
    When I select "Anybody (3)" from "filter_assigned"
    And I wait for .2 seconds
    Then I should see the following tasks:
      | task_list_name | task_name                              |
      | This week      | Post on Digg and Hacker News           |
      | This week      | Tell the tech bloggers                 |
      | Later          | Beg Apple to approve of the iPhone app |

  Scenario: See archived tasks
    Given the task called "Tell my friends" is resolved
    And the task called "Post on Digg and Hacker News" is resolved
    When I go to the "Market Teambox" tasks page
    And I follow "Show 2 archived tasks"
    And I wait for .3 seconds
    Then I should see the following tasks:
      | task_list_name | task_name                    |
      | This week      | Tell my friends              |
      | This week      | Post on Digg and Hacker News |
