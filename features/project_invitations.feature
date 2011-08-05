@signup @javascript
Feature: Invite a user to a project

  Background:
    Given an organization exists with name: "ACME"
    And a project exists with name: "Ruby Rockstars"
    And the project "Ruby Rockstars" belongs to "ACME" organization
    And a confirmed user exists with login: "mislav", first_name: "Mislav", last_name: "Marohnić", email: "mislav@teambox.com"
    And a confirmed user exists with login: "pablo", first_name: "Pablo", last_name: "Villalba", email: "pablo@teambox.com"
    And a confirmed user exists with login: "jordi", first_name: "Jordi", last_name: "Romero", email: "jordi@teambox.com"
    And "mislav" is an administrator in the project called "Ruby Rockstars"
    And "mislav" is an administrator in the organization called "ACME"
    And "pablo" is a participant in the organization called "ACME"
    And "jordi" is a participant in the organization called "ACME"


  Scenario: Mislav invites some friends to a project
    Given I am logged in as @mislav
    When I go to the people page of the "Ruby Rockstars" project
    Then I should see "Invite people to this project"
    And I should see "Mislav Marohnić"
    And I should not see "Remove from project"
    And I should not see "Transfer Ownership"
    When I fill in "invitation_user_or_email" with "invalid user"
    And I press "Invite"
    Then I should see "Invalid usernames or email addresses"
    When I fill in "invitation_user_or_email" with "ed_bloom@spectre.com"
    And I press "Invite"
    Then I should see 'mislav invited ed_bloom@spectre.com to join the project'
    And I should see the unconfirmed email message
    And "ed_bloom@spectre.com" should receive an email

  Scenario: Mislav sends an invitation and tries to accept it while logged in
    Given I am logged in as @mislav
    When I go to the people page of the "Ruby Rockstars" project
    When I fill in "invitation_user_or_email" with "ed_bloom@spectre.com"
    And I press "Invite"
    Then "ed_bloom@spectre.com" should receive an email
    When "ed_bloom@spectre.com" opens the email with subject "Ruby Rockstars"
    And I follow "Accept the invitation to start collaborating" in the email
    Then I should see "You already have an account. Log out first to sign up as a different user."

  Scenario: User creates account and joins project from invitation
    Given "mislav" sent an invitation to "ed_bloom@spectre.com" for the project "Ruby Rockstars"
    When "ed_bloom@spectre.com" opens the email with subject "Ruby Rockstars"
    And they should see "Mislav Marohnić wants to collaborate with you on Teambox" in the email body
    And I should see "Ruby Rockstars" in the email body
    And I follow "Accept the invitation to start collaborating" in the email
    When I fill in "Username" with "bigfish"
    And I fill in "First name" with "Edward"
    And I fill in "Last name" with "Bloom"
    And I fill in "Password" with "tellastory"
    And I fill in "Confirm password" with "tellastory"
    And I press "Create account"
    Then I should see "Ruby Rockstars"
    And I should see "Thanks for signing up!"
    When I go to the people page of the "Ruby Rockstars" project
    Then I should see "Edward Bloom"
    And I should see "Mislav Marohnić"
    Then "mislav@teambox.com" should receive an email
    When "mislav@teambox.com" opens the email
    Then I should see "Edward Bloom has accepted your invitation to Ruby Rockstars" in the email body


  Scenario: Mislav is invited to a project by someone else
    Given I am logged in as @mislav
    And there is a project called "Teambox Roulette"
    When I go to the page of the "Teambox Roulette" project
    Then I should see the unauthorized private project message
    Given the first admin in the project "Teambox Roulette" sent an invitation to "mislav"
    When I go to the page of the "Teambox Roulette" project
    Then I should see "Teambox Roulette"

  Scenario: Mislav invites a user who belongs to the project's organization
    Given I am logged in as @mislav
    When I go to the people page of the "Ruby Rockstars" project
    And I fill in "invitation_user_or_email" with "pablo"
    And I press "Invite"
    Then "pablo@teambox.com" should receive an email
    When "pablo@teambox.com" opens the email
    Then I should see "You are now a member of the project" in the email body
    And I should see "Ruby Rockstars" in the email body

  Scenario: Mislav invites existing teambox users to a project
    Given I am logged in as @mislav
    When I go to the people page of the "Ruby Rockstars" project
    And I fill in "invitation_user_or_email" with "pablo jordi"
    And I press "Invite"
    Then "pablo@teambox.com" should receive an email
    And  "jordi@teambox.com" should receive an email

  Scenario: Mislav invites existing teambox users to a project using mentions
    Given I am logged in as @mislav
    When I go to the people page of the "Ruby Rockstars" project
    And I fill in "invitation_user_or_email" with "@pablo @jordi"
    And I press "Invite"
    Then "pablo@teambox.com" should receive an email
    And  "jordi@teambox.com" should receive an email

  Scenario: Mislav leaves a project

  Scenario: Mislav resends invitation email

  Scenario: Mislav deletes an invitation that hasnt been accepted
    Given I am logged in as @mislav
    When I go to the people page of the "Ruby Rockstars" project
    And I fill in "invitation_user_or_email" with "charles@teambox.com"
    And I press "Invite"
    And I follow "Discard invitation"
    And I wait for 1 second
    Then I should not see "charles@teambox.com"

