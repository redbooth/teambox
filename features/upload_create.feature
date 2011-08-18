@uploads
Feature: Uploading a file

  Background: 
    Given a project exists with name: "Ruby Rockstars"
    And a confirmed user exists with login: "mislav", first_name: "Mislav", last_name: "Marohnić"
    And I am logged in as @mislav
    And I am in the project called "Ruby Rockstars"
    When I go to the uploads page of the "Ruby Rockstars" project
    And I follow "Upload a File"

  Scenario: Mislav uploads a valid file with success
    When I attach the file "features/support/sample_files/dragon.jpg" to "upload_asset"
    And I press "Upload file"
    Then I should see "dragon.jpg" within ".upload"

  Scenario: Mislav tries to upload a file with no asset and fails
    When I press "Upload file"
    Then I should see "There was an error uploading the file"

  Scenario: Mislav tries to upload a file thats too big (that's what she said)
    When I attach a 2MB file to "upload_asset"
    And I press "Upload file"
    Then I should see "There was an error uploading the file"

