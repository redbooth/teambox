@javascript
Feature: Delete Project

  Background: 
    Given @mislav exists and is logged in
    And I am currently in the project ruby_rockstars
    And I go to project settings page

  Scenario: Mislav deletes a project
    Given I follow "Project Archiving/Deletion"
    And I wait for 2 seconds
    And I should see "Archive or Delete project" in the title
    And I should see "Archive this project"
    And I should see "Delete this project forever"
    When I follow "Delete this project forever" confirming with OK
    Then I should see "You deleted the project"

