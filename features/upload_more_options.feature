@uploads @javascript
Feature: Uploading a file

  Background: 
    Given a project exists with name: "Ruby Rockstars"
    And a confirmed user exists with login: "mislav", first_name: "Mislav", last_name: "Marohnić"
    And I am logged in as @mislav
    And I am currently in the project ruby_rockstars
    And I have a task called "Railscast Theme" with a comment including upload "tb-space.jpg"
    
  Scenario: Upload has more options in activity feed
    When I go to the project page
    And I click the element that contain "Railscast Theme" within ".comment"
    And I click the element that contain "More..."
    Then I should see "Download" within ".reference"
    And I should see "Send this file to somebody..." within ".reference"