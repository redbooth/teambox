Feature Creating a task list
  Background:
    Given I am logged in as mislav
      And I am currently in the project ruby_rockstars

  Scenario: Mislav creates a valid task list on my project
    When I go to the task lists page
      And I follow "New Task List"
      And I fill in "task_list_name" with "Finish Writing Specs"
      And I press "Create"
      And I go to the task lists page
     Then I should see "Finish Writing Specs" within ".task_list"
