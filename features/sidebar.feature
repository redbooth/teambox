@javascript
Feature: I navigate using the new sidebar

  Background:
    Given I am logged in as mislav
    And I am in the project called "Earthworks Yoga"
    And the task list called "Stick your fingers there" belongs to the project called "Earthworks Yoga"
    And the task called "Stick your fingers here" is assigned to me
    And I am an administrator in the organization called "Yoga Yogui"

  Scenario: See the sidebar show up properly
    Then I should see the project "Earthworks Yoga"
    Then I should see the task "Stick your fingers there" in the sidebar
    Then I should see the organization "Yoga Yogui" in the sidebar

  Scenario: The links should work properly
    When I follow "My Tasks"
    Then I should see "View all tasks in my projects..."
