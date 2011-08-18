@uploads
Feature: Renaming a file upload

  Background:
    Given a confirmed user exists with login: "mislav", first_name: "Mislav", last_name: "Marohnić"
    And I am logged in as @mislav
    And I am currently in the project ruby_rockstars
    And "tb-space.jpg" has been uploaded to the "Ruby Rockstars" project
    When I go to the uploads page of the "Ruby Rockstars" project

  @javascript
  Scenario: Mislav renames an upload
    When I click upload list item for "tb-space.jpg" file
    And I follow "Rename"
    And I fill in "upload_asset_file_name" with "bye.png"
    And I press "Save"
    Then I should see "bye.png" within ".upload"
