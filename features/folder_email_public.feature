@public_downloads @javascript
Feature: Sending email with a link to public download of a folder
  
  Background: 
    Given a project exists with name: "Ruby Rockstars"
    And a confirmed user exists with login: "mislav", first_name: "Mislav", last_name: "Marohnić"
    And "mislav" is an administrator in the project called "Ruby Rockstars"
    And I am logged in as @mislav
    And I have recently managed the project "Ruby Rockstars"
    And there is a folder called "Rails 2.3.9" in a current project
    And there is a folder called "Rails 3.1.0.rc8" in a current project

  Scenario: Mislav sends public download link
    When I go to the uploads page of the "Ruby Rockstars" project
    And I click upload list item for "Rails 2.3.9" folder
    And I follow "Send this folder to somebody..."
    Then I should see "Enter an Email address to send a link to this folder"
    When I fill in "Email" with "quentin@example.com"
    And I press "Send link"
    Then "quentin@example.com" should receive an email
    And I should see "We just sent a link to the folder to quentin@example.com" within ".flash-notice"
