@organizations
Feature: Public sites for organizations. Allow to view an entrance page and log in

  Background: 
    Given @mislav exists and is logged in
    And the following confirmed users exist
      | login  | email                    | first_name | last_name |
      | pablo  | pablo@teambox.com        | Pablo      | Villalba  |
    And I am currently in the project ruby_rockstars
    And "pablo" is in the project called "Ruby Rockstars"
    And I am an administrator in the organization called "ACME"
    And "pablo" is a participant in the organization called "ACME"
    When I go to the organizations page
    And I follow "ACME"
    And I go to the appearance page for the "ACME" organization
    And I fill in the following:
      | organization_description | <h2>A title!</h2> |
    And I press "Save changes"

  Scenario: I visit the public site of the organization and log in
    Given I log out
    When I go to the public site for "ACME" organization
    Then I should see "A title!" in the title
    When I fill in the following:
      | login     | pablo  |
      | password  | wrong |
    And I press "Login"
    Then I should see an error message: "Couldn't log you in as pablo"
    When I fill in the following:
      | login     | mislav       |
      | password  | dragons      |
    And I press "Login"
    Then I should see "ACME" within "#column"

