@signup @javascript

Feature: Invite users to a project

#              Project Ruby Rockstars
# mislav              admin
# pablo            participant 
# jordi
# jpriu
#
# TODO: Add somebody who's already in the project


  Background:
    Given an organization exists with name: "ACME"
    And a project exists with name: "Ruby Rockstars"
    And the project "Ruby Rockstars" belongs to "ACME" organization
    And a confirmed user exists with login: "mislav", first_name: "Mislav", last_name: "Marohnić", email: "mislav@teambox.com"
    And a confirmed user exists with login: "pablo", first_name: "Pablo", last_name: "Villalba", email: "pablo@teambox.com"
    And a confirmed user exists with login: "jordi", first_name: "Jordi", last_name: "Romero", email: "jordi@teambox.com"
    And a confirmed user exists with login: "jpriu", first_name: "Jordi", last_name: "Priu", email: "jpriu@teambox.com"
    And "mislav" is the owner of the project "Ruby Rockstars"
    And "pablo" is in the project called "Ruby Rockstars"
    And "mislav" is an administrator in the organization called "ACME"
    And "pablo" is a participant in the organization called "ACME"

  Scenario: I invite an existing Teambox user with his email
    Given I am logged in as @mislav
    And I go to the people page of the "Ruby Rockstars" project
    When I fill in "Enter name or email:" with "jordi@teambox.com"
    And I press "Search"
    Then I should see "Jordi Romero"
    And I should see "Select a role for this project"
    And I should see "Invite also to the organization"
    When I press "Invite user to this project"
    #Then I should see "Jordi Romero is now part of this project"
    # TODO: What if he doesn't autoaccept invites?

  Scenario: I invite an existing Teambox user by searching his name
    Given I am logged in as @mislav
    And I go to the people page of the "Ruby Rockstars" project
    When I fill in "Enter name or email:" with "jordi"
    And I press "Search"
    Then I should see "Jordi Romero"
    And I should see "Jordi Priu"
    When I follow "Jordi Romero"
    Then I should see "Jordi Romero"
    And I should see "Select a role for this project"
    And I should see "Invite also to the organization"
    When I press "Invite user to this project"
    #Then I should see "Jordi Romero is now part of this project"
    # TODO: What if he doesn't autoaccept invites?



