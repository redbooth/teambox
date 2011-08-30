@public_downloads @javascript
Feature: Sending email with a link to public download of a file
  
  Background: 
    Given a project exists with name: "Ruby Rockstars"
    And a confirmed user exists with login: "mislav", first_name: "Mislav", last_name: "Marohnić"
    And "mislav" is an administrator in the project called "Ruby Rockstars"
    And "dragon.jpg" has been uploaded to the "Ruby Rockstars" project
    And I am logged in as @mislav
    And I am in the project called "Ruby Rockstars"
    And I go to the uploads page of the "Ruby Rockstars" project


  Scenario: Mislav sends public download link
    When I click upload list item for "dragon.jpg" file
    And I follow "Send this file to somebody..."
    Then I should see "Enter an Email address to send a link to this file"
    When I fill in "Email" with "quentin@example.com"
    And I press "Send link"
    Then "quentin@example.com" should receive an email
    And I should see "We just sent a link to the file to quentin@example.com" within ".flash-notice"

  Scenario: Mislav tries to send public download link but uses wrong email
    When I click upload list item for "dragon.jpg" file
    And I follow "Send this file to somebody..."
    Then I should see "Enter an Email address to send a link to this file"
    When I fill in "Email" with "wrong^@example.com"
    And I press "Send link"
    Then "wrong^@example.com" should receive no emails
    And I should see "Email has not been sent. Invited user email is invalid" within ".flash-error"
