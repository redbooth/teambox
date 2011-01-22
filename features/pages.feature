@javascript
Feature: Making project pages
  Background:
    Given a project exists with name: "Ruby Rockstars"
    And @mislav exists and is logged in
    And I am in the project called "Ruby Rockstars"
  
  Scenario: I create a page
    When I go to the pages of the "Ruby Rockstars" project
      And I follow "New Page" within ".text_actions"
      And I fill in "Name" with "Cool page"
      And I fill in "Description" with "A cool page indeed"
      And I press "Create"
    Then I should see "Cool page"
    And I should see "Text"
    And I should see "Divider"
    And I should see "Image or file"
    And I should see "Edit"
    And I should see "Delete"
  
  Scenario: I create a simple page
    Given the project page "Conferences to Attend" exists in "Ruby Rockstars"
    When I go to the pages of the "Ruby Rockstars" project
    And I follow "Conferences to Attend" within "#pages"
    And I follow "Text"
    And I fill in "Title" with "RailsConf 2011"
    And I fill in "Body" with "Need to research this!"
    And I press "Add Note"
    And I wait for 1 second
    And I follow "Divider"
    And I fill in "divider_name" with "USA"
    And I press "Add"
    And I wait for 1 second
    Then I should see "USA"
    Then I should see "RailsConf 2011"

