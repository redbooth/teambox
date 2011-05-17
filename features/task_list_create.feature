@javascript @tasks
Feature: Creating a task list

  Background: 
    Given @mislav exists and is logged in
    And I am currently in the project ruby_rockstars

  Scenario: Mislav creates a valid task list on my project
    When I go to the task lists page
    And I follow "New Task List"
    And I fill in "task_list_name" with "Finish Writing Specs"
    And I press "Add Task List"
    Then I should see "Finish Writing Specs" within ".task_list"
    And I should see "Finish Writing Specs" within ".head"

  Scenario: Mislav edits a task list name
    Given I have a task list called "Awesome Ruby Yahh"
    And I am on its task list page
    When I reveal all action menus
    And I follow "Rename task list"
    And I wait for 2 seconds
    And I fill in "task_list_name" with "Really Awesome Ruby Yahh" within "form[id$='_edit_form']"
    And I press "Update Task List"
    And I wait for 2 seconds
    Then I should see "Really Awesome Ruby Yahh" within ".head a"

  Scenario: Mislav edits a task list due date
    Given I have a task list called "Awesome Ruby Yahh"
    And I am on its task list page
    When I reveal all action menus
    And I follow "Set the start & end date"
    And I wait for 2 seconds
    And I click on the finish date selector
    And I select the month "January" on the calendar
    And I select the year "2010" on the calendar
    And I select "25" in the calendar
    And I click on the start date selector
    And I select the month "January" on the calendar
    And I select the year "2010" on the calendar
    And I select "15" in the calendar
    And I press "Update Task List"
    And I wait for 2 second
    Then I should see "Jan 15 - Jan 25"
