@organizations
Feature: Creating an organization

  Background: 
    Given @mislav exists and is logged in

  Scenario: I can't create a project with a blank organization
    When I go to the new project page
    When I fill in "Name" with "Bombs Factory"
    And I press "Create project and invite members"
    Then I should see "is too short"

  Scenario: I can't create a project with a short organization name
    When I go to the new project page
    When I fill in "Name" with "Bombs Factory"
    When I fill in "Organization" with "a"
    And I press "Create project and invite members"
    Then I should see "is too short"

  Scenario: I create an organization by creating a project and giving the organization a name
    When I go to the new project page
    When I fill in the following:
      | Project Name              | Rockets Factory |
      | Organization              | ACME            |
    And I press "Create project and invite members"
    Then I should see "Rockets Factory"
    When I go to the organizations page
    Then I should see "ACME" within ".organizations"

  Scenario: I create two projects for a new organization
    When I go to the new project page
    When I fill in the following:
      | Project Name              | Rockets Factory |
      | Organization              | ACME            |
    And I press "Create project and invite members"
    And I go to the new project page
    When I fill in "Name" with "Bombs Factory"
    And I press "Create project and invite members"
    And I go to the organizations page
    When I follow "ACME"
    Then I should see "Bombs Factory"
    And I should see "Rockets Factory"

  Scenario: I create a new organization from the organizations page
    When I go to the organizations page
    And I follow "+ Create a new Organization"
    Then I should see "New Organization"
    When I fill in "organization_name" with "NASA"
    And I press "Create Organization"
    Then I should see "NASA"
    And I should see "There are 1 users"
    And I should see "and 0 projects"

  Scenario: I create two organizations from the organizations page and a project inside each one
    When I go to the organizations page
    And I follow "+ Create a new Organization"
    When I fill in "organization_name" with "NASA"
    And I press "Create Organization"
    When I go to the organizations page
    And I follow "+ Create a new Organization"
    When I fill in "organization_name" with "Pentagon"
    And I press "Create Organization"
    When I go to the organizations page
    Then I should see "NASA"
    And I should see "Pentagon"
    When I go to the new project page
    When I fill in the following:
      | Project Name              | Apollo 13 |
    And I select "NASA" from "project_organization_id"
    And I press "Create project and invite members"
    When I go to the new project page
    When I fill in the following:
      | Project Name              | Spy the president |
    And I select "Pentagon" from "project_organization_id"
    And I press "Create project and invite members"
    When I go to the organizations page
    And I follow "NASA"
    And I follow "Manage projects"
    Then I should see "Apollo 13"
    When I go to the organizations page
    And I follow "Pentagon"
    And I follow "Manage projects"
    And I should see "Spy the president"
