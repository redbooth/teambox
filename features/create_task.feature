Feature Creating a task
  Background:
    Given a project exists with name: "Ruby Rockstars"
    And I am logged in as "mislav"
    And I am in the project called "Ruby Rockstars"
    And the task list called "Awesome Ruby Yahh" belongs to the project called "Ruby Rockstars"

   Scenario: Mislav creates a valid task
      When I go to the "Awesome Ruby Yahh" task list page of the "Ruby Rockstars" project
      When I follow "+ Add Task"
       And I fill in "task_name" with "Ohhh ya"
       And I press "Add Task" within ".task_form"
       And I wait for 1 second
      Then I should see "mislav"
       And I should see "Ohhh ya" within ".taskName .name"

   Scenario Outline: Fails to create a valid task
      When I go to the "Awesome Ruby Yahh" task list page of the "Ruby Rockstars" project
       And I follow "+ Add Task"
       And I fill in "task_name" with "<name>"
       And I press "Add Task" within ".task_form"
      Then I should see "<error_message>" within ".task_form"
   Examples:
     | name | error_message |
     | | must not be blank  |
     | a123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790123456790 | must be shorter than 255 characters |

   Scenario: Mislav edits a task name
     Given a task exists with name: "Ohhh ya"
       And the task called "Ohhh ya" belongs to the task list called "Awesome Ruby Yahh"
       And the task called "Ohhh ya" belongs to the project called "Ruby Rockstars"
      When I go to the page of the "Ohhh ya" task
      When I follow "Edit"
       And I fill in "task_name" with "Uh Ohhh ya"
       And I press "Update Task"
       And I wait for 1 second
      Then I should see "Uh Ohhh ya" within ".task_header h2"

  Scenario: User creates multiple tasks one after the other
    When I go to the "Awesome Ruby Yahh" task list page of the "Ruby Rockstars" project
     And I follow "+ Add Task"
     And I fill in "task_name" with "Metaprogramming" in the new task form of the "Awesome Ruby Yahh" task list
     And I press "Add Task" within ".task_form"
     And I wait for 2 seconds
    Then I should see "Metaprogramming" within ".taskName .name"
    When I follow "+ Add Task"
     And I fill in "task_name" with "Leaking block closures" in the new task form of the "Awesome Ruby Yahh" task list
     And I press "Add Task" within ".task_form"
     And I wait for 2 seconds
    Then I should see "Leaking block closures" within ".taskName .name"

  Scenario: User archives a task
    Given the following task with associations exist:
      | name          | task_list         | project        |
      | Invite Yehuda | Awesome Ruby Yahh | Ruby Rockstars |
   When I go to the page of the "Invite Yehuda" task
    And I click the element "status_resolved"
    And I press "Save"
    And I wait for 2 seconds
   Then I should see "This task is closed and archived"
