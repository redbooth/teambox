@public_downloads
Feature: Public downloads for uploaded files

  Background: 
    Given a project exists with name: "Ruby Rockstars"
    And I have recently managed the project "Ruby Rockstars"
    And "dragon.jpg" has been uploaded to the "Ruby Rockstars" project
    And there is a folder called "Tigers" in a current project
    And "tiger.jpg" has been uploaded to the "Ruby Rockstars" project into the "Tigers" folder

  Scenario: User downloads public file
    When I go to the public download page for "dragon.jpg" file
    Then I should see "dragon.jpg"
    And I should see "This file is shared using Teambox"
    When I follow "dragon.jpg"
    Then I should get a download with the filename "dragon.jpg"

  Scenario: User tries do download a file with wrong token in a link
    When I visit public download page with invalid token
    Then I should see "File not found"

  Scenario: User goes into shared folder
    When I go to the public download page for "Tigers" folder
    Then I should see "tiger.jpg" within ".file_upload"

