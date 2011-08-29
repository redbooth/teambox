@uploads @javascript @moveable
Feature: Moving a file upload

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
    And "tb-space.jpg" has been uploaded to the "Ruby Rockstars" project

  Scenario: Mislav moves a file
    When I go to the uploads page of the "Ruby Rockstars" project
    And I click upload list item for "tb-space.jpg" file
    And I follow "Move to another folder"
    And I select "Director" from target folders list
    And I follow "Move"
    Then I should not see "tb-space.jpg"
    And I should see "2 files" within ".upload"
    When I enter "Director" folder
    Then I should see "tb-space.jpg" within ".file_upload"
    When I click upload list item for "tb-space.jpg" file
    And I follow "Move to another folder"
    And I select "Move to parent folder" from target folders list
    And I follow "Move"
    Then I should not see "tb-space.jpg"
    When I follow "Parent folder"
    Then I should see "tb-space.jpg" within ".file_upload"
