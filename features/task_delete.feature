@javascript @tasks
Feature: Deleting a task

  Background:
    Given a project exists with name: "My pet project"
    And @enric exists and is logged in
    And "enric" is an administrator in the project called "My pet project"
    And the task list called "Stupid tasks" belongs to the project called "My pet project"
    And the task called "Figure what this project is about" belongs to the task list called "Stupid tasks"
    And the task called "Figure what this project is about" belongs to the project called "My pet project"

  Scenario: Enric deletes a task that is not assigned to anybody
    When I go to the page of the "Figure what this project is about" task
    And I follow "Delete" confirming with OK
    Then I should see "Deleted Figure what this project is about task"

  Scenario: Enric deletes a task that is assigned to him
    Given the task called "Figure what this project is about" is assigned to me
    When I go to the page of the "Figure what this project is about" task
    And I follow "Delete" confirming with OK
    Then I should see "Deleted Figure what this project is about task"
