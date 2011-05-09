@javascript @organizations
Feature: Public sites for organizations. Allow to view an entrance page and log in
  In order to discover what has been said about aall topics in my organization
  As an organization admin
  I want to be able to access all projects as an observer

  Background: 
    Given @jordi exists and is logged in
    And the following confirmed users exist
      | login  | email                    | first_name | last_name |
      | pablo  | pablo@teambox.com        | Pablo      | Villalba  |
      | saimon | saimon@teambox.com       | Saimon     | Moore     |
    And @pablo is currently in the project ruby_rockstars
    And I am an administrator in the organization called "ACME"
    And "pablo" is a participant in the organization called "ACME"
    And "saimon" is a participant in the organization called "ACME"
    And there is a project called "Infojobs"
    And the project "Infojobs" belongs to "ACME" organization
    And "saimon" is in the project called "Infojobs"
    And the task list called "Stick your fingers there" belongs to the project called "Ruby Rockstars"
    And the following task with associations exist:
      | name                    | task_list                | project |
      | Stick your fingers here | Stick your fingers there | Teambox |
    And the project page "Conferences to Attend" exists in "Ruby Rockstars"
    And "dragon.jpg" has been uploaded to the "Ruby Rockstars" project
    And @pablo started a conversation named "Can't touch this" in the "Ruby Rockstars" project
    When I go to the manage projects page for the "ACME" organization


  Scenario: I can access the recent activity page for a project in my organization that I don't belong to
    When I follow "Ruby Rockstars"
    Then I should see "Recent activity for Ruby Rockstars"
    And I should see "Ruby Rockstars" within "#column"
    And I should see the recent activity link for the "Ruby Rockstars" project within the sidebar
    And I should see the tasks link for the "Ruby Rockstars" project within the sidebar
    And I should see the conversations link for the "Ruby Rockstars" project within the sidebar
    And I should see the pages link for the "Ruby Rockstars" project within the sidebar
    And I should see the files link for the "Ruby Rockstars" project within the sidebar
    But I should not see the configuration link for the "Ruby Rockstars" project within the sidebar
    And I should not see the people link for the "Ruby Rockstars" project within the sidebar

  Scenario: I can access the task lists page for a project in my organization that I don't belong to
    When I follow "Ruby Rockstars"
    And I follow "Tasks" in the sidebar
    And I wait for 1 second
    Then I should see "Task lists for Ruby Rockstars"
    And I should see "Stick your fingers there" within "#task_lists"
    And I should see "Stick your fingers here" within "#task_lists"
    And I should see "You don't have permission to create tasks in this project" within "#column"

  Scenario: I can access the conversations page for a project in my organization that I don't belong to
    When I follow "Ruby Rockstars"
    And I follow "Conversations" in the sidebar
    And I wait for 1 second
    Then I should see "Conversations in Ruby Rockstars"
    And I should see "Can't touch this" within "#conversations"
    And I should see "You don't have permissions to create a conversation in this project" within "#content"

  Scenario: I can access the pages page for a project in my organization that I don't belong to
    When I follow "Ruby Rockstars"
    And I follow "Pages" in the sidebar
    And I wait for 1 second
    Then I should see "Pages in Ruby Rockstars"
    And I should see "Conferences to Attend" within "#pages"
    And I should see "You don't have permission to create pages in this project" within "#content"

  Scenario: I can access the files page for a project in my organization that I don't belong to
    When I follow "Ruby Rockstars"
    And I follow "Files" in the sidebar
    And I wait for 1 second
    Then I should see "Files in Ruby Rockstars"
    And I should see "dragon.jpg" within "#content"
    And I should see "You don't have permission to upload files to this project" within "#content"

  Scenario: I cannot comment on conversations in a project in my organization that I don't belong to
    When I follow "Ruby Rockstars"
    And I fill in the comment box with "Hammertime"
    And I press "Save"
    And I wait for 1 second
    Then I should not see "Hammertime" within "#activities"

  Scenario: I cannot comment on tasks in a project in my organization that I don't belong to
    When I follow "Ruby Rockstars"
    And I fill in the last comment box with "Stop... Hammer time!"
    And I press the last "Save"
    And I wait for 1 second
    Then I should not see "Stop... Hammer time!" within "#activities"

  Scenario: I cannot invite people to a project in my organization that I don't belong to
    When I go to the people page of the "Ruby Rockstars" project
    Then I should see "Only admins can invite people to this project."
    And I should see "Pablo Villalba"
    But I should not see "Jordi Romero"
    And I should not see "Invite people to this project"
    And I should not see "Transfer Ownership"
    And I should not see "Remove from project"
    When I go to the invite people page of the "Ruby Rockstars" project
    Then I should see "Invite people to Ruby Rockstars"
    When I fill in the invite by email box with "ucanthackthis@hammerti.me"
    And I check the checkbox "Saimon Moore" within "#content .users"
    And I press "Send invitations and start collaborating"
    Then I should see "You are not allowed to do that!"

  Scenario: I cannot modify the settings of a project in my organization that I don't belong to
    When I go to the settings page of the "Ruby Rockstars" project
    Then I should see "You are not allowed to do that!"

  Scenario: I cannot access the new conversation page of a project in my organization that I don't belong to
    When I go to the new conversation page
    Then I should see "You are not authorized to access this page."

  Scenario: I cannot access the new task lists page of a project in my organization that I don't belong to
    When I go to the new task list page
    Then I should see "You are not authorized to access this page."

  Scenario: I cannot access the new page page of a project in my organization that I don't belong to
    When I go to the new page page
    Then I should see "You are not authorized to access this page."

  Scenario: I cannot access the new upload page of a project in my organization that I don't belong to
    When I go to the new upload page
    Then I should see "alert('You are not allowed to do that!')"

