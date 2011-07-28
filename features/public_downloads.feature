@public_downloads
Feature: Public downloads for uploaded files

  Background: 
    Given a project exists with name: "Ruby Rockstars"
    And "dragon.jpg" has been uploaded to the "Ruby Rockstars" project

  Scenario: User downloads public file
    When I go to the public download page for "dragon.jpg" file
    Then I should see "dragon.jpg"
    And I should see "This file was sent using Teambox"
    When I follow "dragon.jpg"
    Then I should get a download with the filename "dragon.jpg"

  Scenario: User tries do download a file with wrong token in a link
    When I visit public download page with invalid token
    Then I should see "File not found"
