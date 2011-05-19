@javascript
Feature: Create task list tempates and convert them to tasks

  Background:
    Given @mislav exists and is logged in
    And I am currently in the project ruby_rockstars
    And I am an administrator in the organization called "ACME"

  Scenario: I create a task list template
    When I go to the task list templates page for the "ACME" organization
    And I follow "New Task List Template"
    And I fill in "task_list_template[name]" with "Hiring process"
    And I fill in "task_list_template[titles][]" with "Gather CVs"
    And I fill in "task_list_template[descs][]" with "Get the best 12 cadidates from Infojobs"
    And I press "Save"
    And I wait for 0.1 seconds
    Then I should see "Hiring process" as the template name
    And I should see "Gather CVs" as a template task name
    And I should see "Get the best 12 cadidates from Infojobs" as a template task description

  Scenario: I create a task list from a template
    Given I have a task list template called "Hiring process"
    When I go to the task lists page
    And I follow "New Task List"
    And I follow "create a Task List from a template"
    And I select "Hiring process" from "template"
    And I press "Add Task List"
    And I wait for 1 seconds
    Then I should see "Hiring process" within ".task_list"
    And I should see "Hiring process" within ".head"

  Scenario: I create a regular task list with templates in the organization
    Given I have a task list template called "Hiring process"
    When I go to the task lists page
    And I follow "New Task List"
    And I fill in "task_list_name" with "Just a regular task list"
    And I press "Add Task List"
    Then I should see "Just a regular task list" within ".task_list"
    And I should not see "Hiring process"

  Scenario: I start creating a regular task list but end up with a template Task List
    Given I have a task list template called "Hiring process"
    When I go to the task lists page
    And I follow "New Task List"
    And I fill in "task_list_name" with "Just a regular task list"
    And I follow "create a Task List from a template"
    And I select "Hiring process" from "template"
    And I press "Add Task List"
    Then I should see "Hiring process" within ".task_list"
    And I should not see "Just a regular task list"

  Scenario: I try to create task list without title but I have templates on the organization
    Given I have a task list template called "Hiring process"
    When I go to the task lists page
    And I follow "New Task List"
    And I press "Add Task List"
    Then I should not see "Just a regular task list"
    And I should see "Name must not be blank"

