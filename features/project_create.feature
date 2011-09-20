Feature: Creating a project

  Background:
    Given @jordi exists and is logged in
    And I go to the new project page

  Scenario Outline: Mislav creates two valid projects and fails to create an invalid project
    When I fill in the following:
      | Name         | <name>   |
      | Organization | ACME     |
    And I press "Create project and invite members"
    Then I should see "<response>"
    And I should see "<flash>"

    Examples: 
      | name                  | response          | flash           |
      | Title with ()_+&-     | Title with ()_+&- | Invite people   |
      | Ruby Rockstars        | Ruby Rockstars    | Invite people   |
      | S                     | S                 | Invite people   |
      | S                     | S                 | Invite people   |

  Scenario: I don't fill in an organization name
    When I fill in "Name" with "Some project"
    And I press "Create project"
    Then I should see "is too short"

  Scenario: I pick up one organization where I'm an admin
    Given I am an administrator in the organization called "ACME"
    And I go to the new project page
    When I fill in "Name" with "ACME Awesome Project"
    And I select "ACME" from "Organization"
    And I press "Create project"
    Then I should see "Invite people"


  Scenario: I ought to have already joined the project I created, not another random project
    Given I am an administrator in the organization called "ACME"
    And I go to the new project page
    When I fill in "Name" with "ACME Awesome Project"
    And I select "ACME" from "Organization"
    And I press "Create project"
    Then I should see "Invite people"
    And I should not see "Join"
    And I go to the new project page                      #We do this two times because we have to make sure that it's the correct (our) project we are added to
    And I fill in "Name" with "ACME Awesome Project #2"
    And I select "ACME" from "Organization"
    And I press "Create project"
    And I go to the projects page
    And I should not see "Join"
