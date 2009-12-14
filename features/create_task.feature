Feature Creating a task
  Background:
       Given I am logged in as mislav
         And I am currently in the project ruby_rockstars
         And I have a task list called "Awesome Ruby Yahh"
         And I am on its task list page
         
   Scenario: Mislav creates a valid task
      When I follow "+ Add Task"
       And I fill in "task_name" with "Ohhh ya"
       And I press "Create" within ".task_form"
      Then I should see "mislav"
       And I should see "Ohhh ya" within ".task_header h2"       
      
   Scenario: Mislav edits a task name
     Given I have a task called "Ohhh ya"
       And I am on its task page
      When I follow "Edit"
       Then show me the page      
       And I fill in "task_name" with "Uh Ohhh ya"
       And I press "Update Task"
      Then I should see "Uh Ohhh ya" within ".task_header h2"
   