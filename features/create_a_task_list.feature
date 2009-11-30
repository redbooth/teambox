Feature Creating a task list
  Background:
    Given I am logged in as mislav
      And I am currently in the project ruby_rockstars

  Scenario: Mislav creates a valid task list on my project
    When I go to the task lists page
      And I click "new_task_list_link"
      And it will auto focus on the name textfield
      And I fill in "Name" with "Finish Writing Specs"
      And I press "Save task"
    Then I should see a new task list at the top of the task list
      And it should be selected
      And the content area show load the comment form with a list of empty tasks