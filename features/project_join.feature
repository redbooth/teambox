@organizations @javascript
Feature: Joining a project, either because it's public or because we're admin of its organization

Background: 
  Given @mislav exists and is logged in
  And the following confirmed users exist
    | login  | email                    | first_name | last_name |
    | pablo  | pablo@teambox.com        | Pablo      | Villalba  |
  And I am currently in the project ruby_rockstars
  And I am an administrator in the organization called "ACME"

Scenario: Pablo joins the project as an admin because he's an administrator in the organization
  Given "pablo" is an administrator in the organization called "ACME"
  And I log out
  When I am logged in as @pablo
  And I go to the organizations page
  And I follow "ACME"
  And I follow "Manage projects"
  When I follow "Ruby Rockstars"
  And I follow "Join this project"
  Then I should see "You're now part of this project"
  When I go to the settings page of the "Ruby Rockstars" project
  Then I should see "General Settings for Ruby Rockstars"

Scenario: Pablo joins the project as a commenter because it's a public project
  Given I go to to the page of the "Ruby Rockstars" project
  And I go to the project settings page
  And I check "project_public"
  And I press "Save Changes"
  And I log out
  When I am logged in as @pablo
  And I go to the public projects page
  And I follow "Ruby Rockstars"
  And I follow "Join this group"
  And I follow "Join this project"
  Then I should see "You're now part of this project"
  When I go to the settings page of the "Ruby Rockstars" project
  Then I should not see "General Settings for Ruby Rockstars"

Scenario: Pablo can't join a project because he's not authorized
  Given I log out
  When I am logged in as @pablo
  And I go to to the page of the "Ruby Rockstars" project
  Then I should see "This is a private project and you're not authorized to access it."
