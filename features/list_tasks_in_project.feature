Feature: List tasks in project broken down by task list

  Background:
    Given I am logged in as mislav
    And I am in the project called "teambox"
    
  Scenario: Task list index
    And the task list called "urgent" belongs to the project called "teambox"    
    And the task called "fix big problem" belongs to the task list called "urgent"
    And the task called "fix big problem" is open
    And the task called "daily reminder email" belongs to the task list called "urgent"
    And the task called "daily reminder email" is resolved
    When I go to the list of tasks page of the project called "teambox"
    Then I should see "fix big problem" within ".content"
    But I should not see "daily reminder email" within ".content"


          
   