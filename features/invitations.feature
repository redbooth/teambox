Feature Invite a user to a project
  Background:
   Given I am logged in as mislav
     And I am currently in the project ruby_rockstars

  Scenario: Mislav invites some friends to a project
    When I go to the people page
    Then I should see "Invite people to this project"
     And I should see "Mislav Marohnić"
     And I should see "Project Owner"
     And I should not see "Remove from project"
     And I should not see "Transfer Ownership"

    When I fill in "invitation_user_or_email" with "invalid user"
     And I press "Invite"
    Then I should see "User or email is not a valid username or email"

    When I fill in "invitation_user_or_email" with "ed_bloom@spectre.com"
     And I press "Invite"
    Then I should see "mislav invited ed_bloom@spectre.com to join the project"
     And I should see "An email was sent to this user, but they still haven't confirmed"
     And "ed_bloom@spectre.com" should receive 1 emails
    When I open the email
     And I should see "Mislav Marohnić wants to collaborate with you on Teambox" in the email body
     And I should see "Ruby Rockstars" in the email body    
     And I follow "Accept the invitation to start collaborating" in the email
    Then I should see "You already have an account. Log out first to sign up as a different user"
    When I log out
     And I follow "Accept the invitation to start collaborating" in the email
    When I fill in "Username" with "bigfish"
     And I fill in "First name" with "Edward"
     And I fill in "Last name" with "Bloom"
     And I fill in "Password" with "tellastory"
     And I fill in "Confirm password" with "tellastory"
     And I press "Create account"
    Then I should see "Ruby Rockstars"
     And I should see "Thanks for signing up!"
    When I go to the people page
    Then I should see "Edward Bloom"
     And I should see "Mislav Marohnić"
      #When I follow "Leave Project"
      
  Scenario: Mislav invites existing teambox users to a project
  Scenario: Mislav leaves a project
  Scenario: Mislav transfers ownership of a project
  Scenario: Mislav resends invitation email
  Scenario: Mislav deletes an invitation that hasnt been accepted