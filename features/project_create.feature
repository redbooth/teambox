Feature: Creating a project

  Background:
    Given @jordi exists and is logged in
    And I go to the new project page

  Scenario Outline: Mislav creates two valid projects and fails to create an invalid project
    When I fill in the following:
      | Name         | <name>   |
      | Organization | ACME     |
    And I press "Create project and start collaborating"
    Then I should see "<response>"
    And I should see "<flash>"

    Examples: 
      | name                  | response          | flash                          |
      | Title with ()_+&-     | Title with ()_+&- | Your project has been created! |
      | Ruby Rockstars        | Ruby Rockstars    | Your project has been created! |
      | Mine                  | Invalid project   | Invalid project                |

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
    Then I should see "Your project has been created"
