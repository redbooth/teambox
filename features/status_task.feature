Feature Changing Task Status from New
  Background:
    Given I am logged in as mislav
      And I am currently in the project ruby_rockstars
      And I have a task list called "Building Killer Dinobots"
      And I have a task called "Installing Megahyper drive"
      And I am on its task page

   Scenario: Mislav doesn't change task (new -> new)
       When I fill in "comment_body" with "I need to wait till the engine cools down"
        And I click the element "status_new"
        And I press "Save"
        And I wait for 0.1 second
       Then I should see "new" within ".task_status_new"
        And I should see "I need to wait till the engine cools down" within ".body"
        And I should see "new" within ".task_header h2"
        And I should see "1" within ".active_new"

   Scenario: Mislav changes task (new -> open:Mislav)
       When I fill in "comment_body" with "I fused the dino eggs to the engine"
        And I select "Mislav Marohnić" from "comment_target_attributes_assigned_id"
        And I press "Save"
       Then I should see "new" within ".task_status_new"
        And I should see "→" within ".comment .status_arr"
        And I should see "M. Marohnić" within ".task_status_open"
        And I should see "I fused the dino eggs to the engine" within ".body"
        And I should see "open" within ".task_header h2"
        And I should see "Mislav Marohnić" within ".assignment"
        And I should see "1" within ".active_open"

   Scenario: Mislav changes task (new -> hold)
      When I fill in "comment_body" with "I need to wait till the engine cools down"
        And I click the element "status_hold"
       # And I choose "comment_status_2"
       And I press "Save"
      Then I should see "new" within ".task_status_new"
       And I should see "→" within ".comment .status_arr"
       And I should see "hold" within ".task_status_hold"
       And I should see "I need to wait till the engine cools down" within ".body"
       And I should see "hold" within ".task_header h2"
       And I should see "1" within ".active_hold"

   Scenario: Mislav changes task (new -> resolved)
       When I fill in "comment_body" with "I need to wait till the engine cools down"
        And I click the element "status_resolved"
        And I press "Save"
       Then I should see "new" within ".task_status_new"
        And I should see "→" within ".comment .status_arr"
        And I should see "resolved" within ".task_status_resolved"
        And I should see "I need to wait till the engine cools down" within ".body"
        And I should see "resolved" within ".task_header h2"
        And I should see "1" within ".active_resolved"

   Scenario: Mislav changes task (new -> rejected)
       When I fill in "comment_body" with "I need to wait till the engine cools down"
        And I click the element "status_rejected"
        And I press "Save"
       Then I should see "new" within ".task_status_new"
        And I should see "→" within ".comment .status_arr"
        And I should see "rejected" within ".task_status_rejected"
        And I should see "I need to wait till the engine cools down" within ".body"
        And I should see "rejected" within ".task_header h2"
        And I should see "1" within ".active_rejected"

  Scenario: Mislav shouldn't be able to change task (hold -> new)
  Scenario: Mislav doesn't change task (hold -> hold)
  Scenario: Mislav changes task (hold -> resolved)
     Given I have a task on hold
      When I fill in "comment_body" with "done!"
       And I click the element "status_resolved"
       And I press "Save"
       And I should see "hold" within ".task_status_hold"
       And I should see "→" within ".comment .status_arr"
       And I should see "resolved" within ".task_status_resolved"
       And I should see "done!" within ".body"
       And I should see "resolved" within ".task_header h2"
       And I should see "2" within ".active_resolved"

  Scenario: Mislav changes task (hold -> rejected)
     Given I have a task on hold
      When I fill in "comment_body" with "done!"
       And I click the element "status_rejected"
       And I press "Save"
       And I should see "hold" within ".task_status_hold"
       And I should see "→" within ".comment .status_arr"
       And I should see "rejected" within ".task_status_rejected"
       And I should see "done!" within ".body"
       And I should see "rejected" within ".task_header h2"
       And I should see "2" within ".active_rejected"

  Scenario: Mislav shouldn't be able to change task (rejected -> new)
  Scenario: Mislav doesn't change task (rejected -> rejected)
  Scenario: Mislav changes task (rejected -> open:Mislav)

  Scenario: Mislav changes task (rejected -> hold)
    Given I have a task on rejected
     Then I should see "Archive this task"
     Then I should see "Reopen this task"
      But I should not see ".comment_body"

  Scenario: Mislav changes task (rejected -> resolved)
    Given I have a task on rejected
     Then I should see "Archive this task"
     Then I should see "Reopen this task"
      But I should not see ".comment_body"

  Scenario: Mislav shouldn't be able to change task (resolved -> new)
  Scenario: Mislav changes task (resolved -> open:Mislav)
  Scenario: Mislav changes task (resolved -> hold)
  Scenario: Mislav doesn't change task (resolved -> resolved)
  Scenario: Mislav changes task (resolved -> rejected)
    Given I have a task on resolved
     Then I should see "Archive this task"
     Then I should see "Reopen this task"
      But I should not see ".comment_body"
