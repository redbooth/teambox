@javascript
Feature: Folders

  Background:
    Given a confirmed user exists with login: "mislav", first_name: "Mislav", last_name: "Marohnić"
    And I am logged in as @mislav
    And I am currently in the project ruby_rockstars
    When I go to the uploads page of the "Ruby Rockstars" project
    And I follow "New Folder"
    Then I should see New Folder form

  Scenario: Mislav creates a valid folder with success
    When I fill in the form name with "Rails 6.0 features"
    And I press "Create folder"
    Then I should be on the page of the "Rails 6.0 features" folder
    And I should see "Rails 6.0 features" within ".breadcrumbs"


