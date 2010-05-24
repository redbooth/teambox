Feature: Update Project
 Background:
      Given I am logged in as mislav
        And I am currently in the project ruby_rockstars
        And I go to project settings path

   Scenario: Mislav archives a project
      Given I follow "General Settings"
        And I should see "General Settings" within "h2"
        When I check "project_archived"
        And I press "Save Changes"
       Then I should see "This project is archived. To edit or comment on this project you must unarchive it on the Project Settings page" within ".strip"
       