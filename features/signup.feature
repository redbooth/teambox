Feature: Sigining up

Scenario: Mislav successfully signs up and confirms his email
  Given I am on the home page
  And I follow "Signup"
  When I fill in "Username" with "mislav"
  And I fill in "First name" with "Mislav"
  And I fill in "Last name" with "Marohnić"
  And I fill in "Email" with "mislav@fuckingawesome.com"
  And I fill in "Password" with "makeabarrier"
  And I fill in "Confirm Password" with "makeabarrier"
  And I press "Create account"
  Then I should see "Confirm your email"
  And "mislav@fuckingawesome.com" should receive 1 email
  When I open the email
  And I should see "Hey, Mislav Marohnić!" in the email body
  And I follow "Log into Teambox now!" in the email
  And I should see "Welcome"  