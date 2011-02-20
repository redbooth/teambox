@signup
Feature: Resetting passwords
  In order to reset their passwords
  Users should be able to
  enter their email and receive a reset password link

  Background: 
    Given the following confirmed users exist
      | login | email             | first_name | last_name |
      | pablo | pablo@teambox.com | Pablo      | Villalba  |

  Scenario: I try resetting the password for a non existing user
    Given I am on the login page
    When I follow "Forgot your password?"
    And I fill in "Email" with "non-existing@email.com"
    And I press "Send me a link to reset my password"
    Then I should see "We can't find a user with that email: non-existing@email.com"
    And "non-existing@email.com" should receive no emails

  Scenario: Mislav forgot his password, so he will recover it using the form
    Given I am on the login page
    And I am the user mislav
    When I follow "Forgot your password?"
    Then I should see "So you forgot your password?"
    When I fill in "Email" with "mislav@fuckingawesome.com"
    And I press "Send me a link to reset my password"
    Then I should see "We just sent you an email to mislav@fuckingawesome.com so you can retrieve your password."
    And "mislav@fuckingawesome.com" should receive an email
    When I open the email
    Then I should see "Hey, Mislav Marohnić!" in the email body
    When I follow "Log into Teambox now!" in the email
    Then I should see "You can now reset your password"
    When I fill in "Password" with "thirstycups"
    And I fill in "Password confirmation" with "thirstycups"
    And I press "Reset my password"
    Then I should see "Password was successfully updated."
    Then I should see "All Projects"

  # test what happens if a user already logged in uses a code
  # test for invalid or expired things
  Scenario: User leaves the (new) password field blank
    Given a confirmed user exists with login: "balint", email: "balint@codigoergosum.com"
    And the user with login: "balint" has asked to reset his password
    When I follow the reset password link
    And I press "Reset my password"
    Then I should see an error message: "New password is not valid. Try again."
    And I should see "Please enter a new password and confirm it"

  Scenario: A user who still didn't confirm his account reset passwords and confirms his account by doing so
    Given I am on the login page
    And I am the user mislav
    And I have never confirmed my email
    When I follow "Forgot your password?"
    When I fill in "Email" with "mislav@fuckingawesome.com"
    And I press "Send me a link to reset my password"
    And "mislav@fuckingawesome.com" should receive an email
    When I open the email
    When I follow "Log into Teambox now!" in the email
    When I fill in "Password" with "thirstycups"
    And I fill in "Password confirmation" with "thirstycups"
    And I press "Reset my password"
    Then I should see "Password was successfully updated."
    And I should see "All Projects"

  Scenario: Deleted user tries to reset password
    Given the user with login: "pablo" is deleted
    And I am on the forgot password page
    When I fill in "Email" with "pablo@teambox.com"
    And I press "Send me a link to reset my password"
    Then I should see "We can't find a user with that email"
    And "pablo@teambox.com" should receive 0 emails

  Scenario: Deleted user tries to use a previously generated reset code
    Given the user with login: "pablo" has asked to reset his password
    And the user with login: "pablo" is deleted
    When I follow the reset password link
    Then I should see "The change password URL you visited is either invalid or expired"

