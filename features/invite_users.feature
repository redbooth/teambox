Feature Invite users

  Scenario: Mislav invites some friends to a project
    Given I am logged in as mislav
    # All this block should be: And a project exists with name: "ruby_rockstars"
    When I go to the new project page
    And I fill in "Name" with "Ruby Rockstars"
    And I fill in "URL" with "ruby_rockstars"
    And I press "Create project and start inviting people"
    Then I should see "Ruby Rockstars"
    ##

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
    And I fill in "Confirm Password" with "tellastory"
    And I press "Create account"
    Then I should see "Ruby Rockstars"
    And I should see "Thanks for signing up!"
    When I go to the people page
    Then I should see "Edward Bloom"
    And I should see "Mislav Marohnić"
    #When I follow "Leave Project"
    And I should write features for inviting an existing user
    And I should write features for leave project
    And I should write features for transfer ownership
    And I should write features for resend invitation email
    And I should write features for deleting an invitation that has not been accepted

