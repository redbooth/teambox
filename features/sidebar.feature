@javascript
Feature: I navigate using the new sidebar

  Background:
    Given @mislav exists and is logged in
    And I am currently in the project ruby_rockstars
    And the task list called "Stick your fingers there" belongs to the project called "Ruby Rockstars"
    And the task called "Stick your fingers here" belongs to the task list called "Stick your fingers there"
    And the task called "Stick your fingers here" is assigned to me
    And I am an administrator in the organization called "ACME"
    And I go to the projects page

  Scenario: See the sidebar show up properly
    Then I should see the project "Ruby Rockstars"
    Then I should see the task "Stick your fingers there" in the sidebar
    When I follow "Organizations" in the sidebar
    Then I should see the organization "ACME" in the sidebar

  Scenario: The links should work properly
    When I follow "My Tasks"
    Then I should see "View all tasks in my projects..."

  Scenario: Anyo participant should see People & Permissions in project menu
    Given @artur exists and is logged in
    And I am in the project called "Ruby Rockstars"
    When I go to the projects page
    Then I should see the project "Ruby Rockstars"
    When I follow "Ruby Rockstars"
    Then I should see "People & Permissions" within "#my_projects_list"
