@folders
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

  @javascript
  Scenario: Mislav renames a folder
    Given there is a folder called "Ruby 1.9 features" in a current project
    When I go to the uploads page of the "Ruby Rockstars" project
    And I click upload list item for "Ruby 1.9 features" folder
    And I follow "Rename"
    And I fill in "folder_name" with "Ruby 2.0 features"
    And I press "Save"
    Then I should see "Ruby 2.0 features" within ".upload"

  Scenario: Mislav browses a tree and uploads a file
    Given a current project has nested folders
    | name         |
    | Director     |
    | Tarantino    |
    | Pulp Fiction |
    | Mia Wallace  |
    When I go to the uploads page of the "Ruby Rockstars" project
    And I enter "Director" folder
    Then I should be on the page of the "Director" folder
    And I enter "Tarantino" folder
    Then I should be on the page of the "Tarantino" folder
    And I enter "Pulp Fiction" folder
    Then I should be on the page of the "Pulp Fiction" folder
    And I follow "Parent folder"
    Then I should be on the page of the "Tarantino" folder
    And I follow "Director" within ".breadcrumbs"
    Then I should be on the page of the "Director" folder
    When I follow "Upload a File"
    And I attach the file "features/support/sample_files/dragon.jpg" to "upload_asset"
    And I press "Upload file"
    Then I should see "dragon.jpg" within ".file_upload"


