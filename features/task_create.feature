@javascript @tasks
Feature: Creating a task

  Background: 
    Given a project exists with name: "Ruby Rockstars"
    And @mislav exists and is logged in
    And I am in the project called "Ruby Rockstars"
    And the task list called "Awesome Ruby Yahh" belongs to the project called "Ruby Rockstars"

  Scenario: Mislav creates a valid task
    When I go to the "Awesome Ruby Yahh" task list page of the "Ruby Rockstars" project
    When I follow "+ Add Task"
    And I fill in "Task title" with "Ohhh ya"
    And I press "Add Task"
    And I wait for 1 second
    Then I should see "mislav"
    And I should see "Ohhh ya" as a task name

  Scenario: Mislav creates a valid task with an upload
    When I go to the "Awesome Ruby Yahh" task list page of the "Ruby Rockstars" project
    When I follow "+ Add Task"
    And I fill in "Task title" with "Ohhh upload"
    And I follow "Attachment"
    When I attach the file "features/support/sample_files/dragon.jpg" to "upload_file"
    And I press "Add Task"
    And I wait for 1 second
    And I should see "Ohhh upload" as a task name

  Scenario: Mislav creates a valid task with urgent flag
    When I go to the "Awesome Ruby Yahh" task list page of the "Ruby Rockstars" project
    When I follow "+ Add Task"
    And I fill in "Task title" with "Ohhh upload"
    And I click the element that contain "No date assigned" within "#new_task"
    And I check "Urgent, to be done as soon as possible" within ".calendar_date_select"
    And I press "Add Task"
    And I wait for 1 second
    And I should see "Ohhh upload" as a task name
    And I should see "Urgent" within "span.urgent"

  Scenario: Fails to create a task without a title
    When I go to the "Awesome Ruby Yahh" task list page of the "Ruby Rockstars" project
    And I follow "+ Add Task"
    And I fill in "Task title" with ""
    And I press "Add Task"
    Then I should see 'must not be blank'

  Scenario Outline: Fails to create a valid task
    When I go to the "Awesome Ruby Yahh" task list page of the "Ruby Rockstars" project
    And I follow "+ Add Task"
    And I fill in "Task title" with "<name>"
    And I press "Add Task"
    Then I should see "<error_message>"

    Examples: 
      | name                                                                                                                                                                                                                                                                                                                                                                      | error_message                       |
      |                                                                                                                                                                                                                                                                                                                                                                           | must not be blank                   |
      | a123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790 | must be shorter than 255 characters |

  Scenario: Mislav edits a task name
    Given a task exists with name: "Ohhh ya"
    And the task called "Ohhh ya" belongs to the task list called "Awesome Ruby Yahh"
    And the task called "Ohhh ya" belongs to the project called "Ruby Rockstars"
    When I go to the page of the "Ohhh ya" task
    When I follow "Edit"
    And I fill in "Task title" with "Uh Ohhh ya"
    And I press "Update Task"
    And I wait for 1 second
    Then I should see "Uh Ohhh ya" in the title

  Scenario: User creates multiple tasks one after the other
    When I go to the "Awesome Ruby Yahh" task list page of the "Ruby Rockstars" project
    And I follow "+ Add Task"
    And I fill in "Task title" with "Metaprogramming"
    And I press "Add Task"
    And I wait for 1 seconds
    Then I should see "Metaprogramming" as a task in the task list
    When I fill in "Task title" with "Leaking block closures"
    And I press "Add Task"
    And I wait for 1 seconds
    Then I should see "Leaking block closures" as a task in the task list
