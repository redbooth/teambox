@javascript @tasks
Feature: Changing Task Status from New

  Background: 
    Given I am logged in as mislav
    And I am currently in the project ruby_rockstars
    And I have a task list called "Building Killer Dinobots"
    And I have a task called "Installing Megahyper drive"
    And I am on its task page

  Scenario: Mislav doesn't change task (new -> new)
    When I fill in the comment box with "I need to wait till the engine cools down"
    And I select "new" from "Status"
    And I press "Save"
    And I wait for 0.2 second
    And I should see "I need to wait till the engine cools down"
    And I should see "Status: new"

  Scenario: Mislav changes task (new -> open:Mislav)
    When I fill in the comment box with "I fused the dino eggs to the engine"
    And I select "Mislav Marohnić" from "Assigned to"
    And I press "Save"
    Then I should see "Status: open"
    And I should see "Assigned to Mislav Marohnić"

  Scenario: Mislav changes task (new -> hold)
    When I fill in the comment box with "I need to wait till the engine cools down"
    And I select "hold" from "Status"
    And I press "Save"
    And I wait for .2 seconds
    Then I should see "new → hold"
    And I should see "I need to wait till the engine cools down"
    And I should see "Status: hold"

  # And I choose "comment_status_2"
  Scenario: Mislav changes task (new -> resolved)
    When I fill in the comment box with "I need to wait till the engine cools down"
    And I select "resolved" from "Status"
    And I press "Save"
    And I wait for .2 seconds
    Then I should see "new → resolved"
    And I should see "I need to wait till the engine cools down"
    And I should see "Status: resolved"

  Scenario: Mislav changes task (new -> rejected)
    When I fill in the comment box with "I need to wait till the engine cools down"
    And I select "rejected" from "Status"
    And I press "Save"
    And I wait for .2 seconds
    Then I should see "new → rejected"
    And I should see "I need to wait till the engine cools down"
    And I should see "Status: rejected"

  Scenario: Mislav shouldn't be able to change task (hold -> new)

  Scenario: Mislav doesn't change task (hold -> hold)

  Scenario: Mislav changes task (hold -> resolved)
    Given I have a task on hold
    When I fill in the comment box with "done!"
    And I select "resolved" from "Status"
    And I press "Save"
    And I wait for .2 seconds
    And I should see "hold → resolved"
    And I should see "done!"
    And I should see "Status: resolved"

  Scenario: Mislav changes task (hold -> rejected)
    Given I have a task on hold
    When I fill in the comment box with "done!"
    And I select "rejected" from "Status"
    And I press "Save"
    And I wait for .2 seconds
    And I should see "hold → rejected"
    And I should see "done!"
    And I should see "Status: rejected"

  Scenario: Mislav shouldn't be able to change task (rejected -> new)

  Scenario: Mislav doesn't change task (rejected -> rejected)

  Scenario: Mislav changes task (rejected -> open:Mislav)

  Scenario: Mislav changes task (rejected -> hold)
    Given I have a task on rejected
    Then I should see "This task is closed and archived"
    Then I should see "Reopen this task"
    But I should not see ".comment_body"

  Scenario: Mislav shouldn't be able to change task (resolved -> new)

  Scenario: Mislav changes task (resolved -> open:Mislav)

  Scenario: Mislav changes task (resolved -> hold)

  Scenario: Mislav doesn't change task (resolved -> resolved)

  Scenario: Mislav changes task (resolved -> rejected)
    Given I have a task on resolved
    Then I should see "This task is closed and archived"
    Then I should see "Reopen this task"
    But I should not see ".comment_body"

