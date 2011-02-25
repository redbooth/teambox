@javascript
Feature: First steps guide for initiations

  Background:
    Given a project with user @mislav
    And I am logged in as @mislav
    And I am an administrator in the organization called "ACME"
    And I have badges enabled
    And I have first steps enabled

  Scenario: I collect all badges and hide the First Steps achievements forever
    When I go to the projects page
    Then I should see "Your first steps in Teambox"

    When I go to the new project page
    And I fill in "Name" with "ACME Awesome Project"
    And I select "ACME" from "Organization"
    And I press "Create project"
    Then I should see "get started"
    And I should see "Invite your team to your projects"

    When I fill in "project[invite_emails]" with "some@people.com"
    And I press "Send invitations and start collaborating"
    Then I should see "Invitations sent"
    And I should see "Post your first conversation"

    When I fill in "conversation[comments_attributes][0][body]" with "wowow"
    And I press "Save"
    Then I should see "Your first Conversation"
    And I should see "Create your first task"

    Given I am in the project called "Ruby Rockstars"
    And the task list called "Awesome Ruby Yahh" belongs to the project called "Ruby Rockstars"
    When I go to the "Awesome Ruby Yahh" task list page of the "Ruby Rockstars" project
    When I follow "+ Add Task"
    And I fill in "Task title" with "Ohhh ya"
    And I press "Add Task"
    And I wait for 1 second
    Then I should see "Your first Task"
    And I should see "Create your first page"

    Given I am in the project called "Ruby Rockstars"
    When I go to the pages of the "Ruby Rockstars" project
    And I follow "New Page" within ".text_actions"
    And I fill in "Name" with "Cool page"
    And I fill in "Description" with "A cool page indeed"
    And I press "Create"
    Then I should see "Your first Page"
    And I should see "Initiation complete"

    When I follow "[ Close this first steps guide ]"
    And I wait for 1 second
    When I go to the projects page
    Then I should not see "Your first steps in Teambox"
