@javascript
Feature: Delete Project

  Background: 
    Given I am logged in as mislav
    And I am currently in the project ruby_rockstars
    And I go to project settings page

  Scenario: Mislav deletes a project
    Given I follow "Project Archiving/Deletion"
    And I should see "Archive/Delete Project" in the title
    And I should see "Archive this project"
    And I should see "Delete this project forever"
    When I follow "Delete this project forever" confirming with OK
    Then I should see "You deleted the project"

