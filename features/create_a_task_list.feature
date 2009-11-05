Feature Creating a task list

  Scenario: A logged in user creating a valid task list on my project
    Given I am logged in as a user
    When I go to the show page for that task list
    And I click "new_task_list_link"
    And a task lists form appear
    And it will auto focus on the name textfield
    And I fill in "Name" with "Finish Writing Specs"
    And I press "Save task"
    Then I should see a new task list at the top of the task list
    And it should be selected
    And the content area show load the comment form with a list of empty tasks