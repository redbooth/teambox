Feature: Update Project

  Background: 
    Given @mislav exists and is logged in
    And I am currently in the project ruby_rockstars
    And I go to project settings page

  Scenario: Mislav archives a project
    Given I follow "General Settings"
    And I should see "General Settings" in the title
    When I check "project_archived"
    And I press "Save Changes"
    Then I should see "This project is archived. To edit or comment on this project you must unarchive it on the Project Settings page"
