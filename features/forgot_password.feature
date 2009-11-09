Feature: Forgot Password

  Scenario: Mislav forgot his password, so he will recover it using the form
    Given I am the user mislav
    And I am on the login page
    And I follow "Forgot your password?"
    When I fill in "Email" with "mislav@fuckingawesome.com"
    And I press "Send me a link to reset my password"
    Then I should see "We just sent you an email to mislav@fuckingawesome.com so you can retrieve your password."
    And "mislav@fuckingawesome.com" should receive 1 email
    And I open the email
    And I should see "Hey, Mislav Marohnić!" in the email body
    And I follow "Log into Teambox now!" in the email
    And I should see "You can now reset your password!"
    And I fill in "Password" with "thirstycups"
    And I fill in "Confirm Password" with "thirstycups"
    And I press "Reset password!"
    And I should see "Password was successfully updated. Please log in."
    And I fill in "login" with "mislav"
    And I fill in "password" with "thirstycups"
    And I press "Login"
    And I should see "All Projects" 