@organizations
Feature: Joining organizations

  Background: 
    Given @mislav exists and is logged in
    And the following confirmed users exist
      | login  | email                    | first_name | last_name |
      | pablo  | pablo@teambox.com        | Pablo      | Villalba  |
      | jordi  | jordi@teambox.com        | Jordi      | Romero    |
    And I am currently in the project ruby_rockstars
    And I am an administrator in the organization called "ACME"
    And "pablo" is a participant in the organization called "ACME"
    And I go to the people page of the "Ruby Rockstars" project

  Scenario: Mislav invites Pablo to a project, but not to the organization
    Given I fill in "invitation_user_or_email" with "pablo"
    And I select "Admin. Can invite users to the project, and delete comments." from "invitation_role"
    And I select "Don't invite. User won't be able to create projects in this organization." from "invitation_membership"
    And I press "Invite"
    #Invite will be autoaccepted as pablo belongs to project's organization
    Then "pablo" should belong to the organization "ACME" as a participant
    And "pablo" should belong to the project "Ruby Rockstars" as an admin

  Scenario: Mislav invites Pablo to a project and to the organization as a participant
    Given I fill in "invitation_user_or_email" with "pablo"
    And I select "Admin. Can invite users to the project, and delete comments." from "invitation_role"
    And I select "As a participant. Will be able to create his own projects." from "invitation_membership"
    And I press "Invite"
    #Invite will be autoaccepted as pablo belongs to project's organization
    Then "pablo" should belong to the organization "ACME" as a participant
    And "pablo" should belong to the project "Ruby Rockstars" as an admin

  Scenario: Mislav invites Pablo to a project and to the organization as a participant
    Given I fill in "invitation_user_or_email" with "pablo"
    And I select "Admin. Can invite users to the project, and delete comments." from "invitation_role"
    And I select "As an administrator. Will be able to add new users and manage the organization." from "invitation_membership"
    And I press "Invite"
    #Invite will be autoaccepted as pablo belongs to project's organization
    Then "pablo" should belong to the organization "ACME" as a admin
    And "pablo" should belong to the project "Ruby Rockstars" as an admin

  Scenario: Mislav invites Jordi to a project, but not to the organization
    Given I fill in "invitation_user_or_email" with "jordi"
    And I select "Admin. Can invite users to the project, and delete comments." from "invitation_role"
    And I select "Don't invite. User won't be able to create projects in this organization." from "invitation_membership"
    And I press "Invite"
    Then "jordi" should not belong to the organization "ACME"
    And "jordi" should belong to the project "Ruby Rockstars" as an admin

  Scenario: Mislav invites Jordi to a project and to the organization as a participant
    Given I fill in "invitation_user_or_email" with "jordi"
    And I select "Admin. Can invite users to the project, and delete comments." from "invitation_role"
    And I select "As a participant. Will be able to create his own projects." from "invitation_membership"
    And I press "Invite"
    Then "jordi" should belong to the organization "ACME" as a participant
    And "jordi" should belong to the project "Ruby Rockstars" as an admin

  Scenario: Mislav invites Jordi to a project and to the organization as a participant
    Given I fill in "invitation_user_or_email" with "jordi"
    And I select "Admin. Can invite users to the project, and delete comments." from "invitation_role"
    And I select "As an administrator. Will be able to add new users and manage the organization." from "invitation_membership"
    And I press "Invite"
    Then "jordi" should belong to the organization "ACME" as a admin
    And "jordi" should belong to the project "Ruby Rockstars" as an admin

