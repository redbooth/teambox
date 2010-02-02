Feature: Resetting passwords
  In order to reset their passwords
  Users should be able to
  enter their email and receive a reset password link

Scenario: I visit forgot password page
  Given I am on the home page
  When I follow "Forgot your password?"
  Then I should see "So you forgot your password?"

Scenario: I try resetting the password for a non existing user
  Given I am on the forgot password page
  When I fill in "Email" with "non-existing@email.com"
   And I press "Send me a link to reset my password"
  Then I should see "We can't find a user with that email: non-existing@email.com"
   And "non-existing@email.com" should receive 0 emails

Scenario: Mislav forgot his password, so he will recover it using the form
  Given I am on the forgot password page
    And I am the user mislav
   When I fill in "Email" with "mislav@fuckingawesome.com"
    And I press "Send me a link to reset my password"
   Then I should see "We just sent you an email to mislav@fuckingawesome.com so you can retrieve your password."
    And "mislav@fuckingawesome.com" should receive 1 email
   When I open the email
   Then I should see "Hey, Mislav Marohnić!" in the email body
   When I follow "Log into Teambox now!" in the email
   Then I should see "You can now reset your password!"
   When I fill in "Password" with "thirstycups"
    And I fill in "Confirm Password" with "thirstycups"
    And I press "Reset password!"
   Then I should see "Password was successfully updated. Please log in."
   When I fill in "login" with "mislav"
    And I fill in "password" with "thirstycups"
    And I press "Login"
   Then I should see "All Projects"
   When I log out
    And I fill in "login" with "mislav@fuckingawesome.com"
    And I fill in "password" with "thirstycups"
    And I press "Login"
   Then I should see "You don't own or belong to any projects yet"

# test what happens if a user already logged in uses a code
# test for invalid or expired things

@wip
Scenario: User leaves the (new) password field blank
  Given a confirmed user exists with login: "balint", email: "balint@codigoergosum.com"
  And the user with login: "balint" has asked to reset his password
  When I follow the reset password link
  And I press "Reset password!"
  Then I should see an error message: "New password is not valid. Try again."
  And I should see "Please enter a new password and confirm it"
