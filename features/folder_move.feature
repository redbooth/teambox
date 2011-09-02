@uploads @javascript @moveable @folders
Feature: Moving a folder

  Background:
    Given a confirmed user exists with login: "mislav", first_name: "Mislav", last_name: "Marohnić"
    And I am logged in as @mislav
    And I am currently in the project ruby_rockstars
    Given a current project has nested folders
    | name         |
    | Director     |
    | Tarantino    |
    | Pulp Fiction |
    | Mia Wallace  |

  Scenario: Mislav moves a file
    When I go to the uploads page of the "Ruby Rockstars" project
    And I enter "Director" folder
    And I enter "Tarantino" folder
    And I enter "Pulp Fiction" folder
    And I click upload list item for "Mia Wallace" folder
    And I follow "Move to another folder"
    And the "#target_folder_id" select should contain the option "Move to parent folder"
    And the "#target_folder_id" select should not contain the option "Mia Wallace"
    And I select "Move to parent folder" from target folders list
    And I follow "Move"
    Then I should not see "Mia Wallace" within ".upload"
    When I follow "Parent folder"
    Then I should see "Mia Wallace" within ".upload"
    When I click upload list item for "Mia Wallace" folder
    And I follow "Move to another folder"
    And I select "Move to parent folder" from target folders list
    And I follow "Move"
    Then I should not see "Mia Wallace" within ".upload"
    When I follow "Parent folder"
    Then I should see "Mia Wallace" within ".upload"
    When I click upload list item for "Mia Wallace" folder
    And I follow "Move to another folder"
    And I select "Tarantino" from target folders list
    And I follow "Move"
    Then I should not see "Mia Wallace" within ".upload"
    When I enter "Tarantino" folder
    Then I should see "Mia Wallace" within ".upload"

  Scenario: Mislav deletes folder and checks if it still appears on the target folders list
    When there is a folder called "Rails 2.3.5" in a current project
    And there is a folder called "Rails 2.3.8" in a current project
    And there is a folder called "Rails 3.0.1" in a current project
    And there is a folder called "Rails 3.1.0.rc8" in a current project
    When I go to the uploads page of the "Ruby Rockstars" project
    And I click upload list item for "Rails 2.3.5" folder
    And I follow "Delete"
    When I confirm alert message
    Then I should not see "Rails 2.3.5" within ".upload"
    When I click upload list item for "Rails 3.1.0.rc8" folder
    And I follow "Move to another folder"
    Then the "#target_folder_id" select should not contain the option "Rails 2.3.5"
