@javascript
Feature: Leaving a project

  Background:
    Given the following confirmed users exist
      | login  | email                    | first_name | last_name |
      | pablo  | pablo@teambox.com        | Pablo      | Villalba  |
    Given @mislav exists and is logged in
    And I am currently in the project ruby_rockstars
    And "pablo" is in the project called "Ruby Rockstars"
  
  Scenario: Mislav removes a person
    Given I go to the people page of the "Ruby Rockstars" project
    When I follow "Remove" within "#people" confirming with OK
    And I wait for 1 second
    Then I should not see "Pablo"
    And I should see "Mislav"
