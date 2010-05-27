Feature: Delete Project
  Background:
       Given I am logged in as mislav
         And I am currently in the project ruby_rockstars
         And I go to project settings path

    Scenario: Mislav deletes a project
       Given I follow "Project Archiving/Deletion"
         And I should see "Archive/Delete Project" within "h2"
         And I should see "Archive this project" within "a.button"
         And I should see "Delete this project forever" within "a.button"
        When I follow "Delete this project forever"
         #And I press "Save Changes"
        #Then I should see "This project is currently archived. If you want to edit or comment on this project you must unarchive it" within ".strip"
