Feature: Sigining up

Scenario: Mislav successfully signs up and confirms his email
  Given I am on the home page
    And I follow "Signup"
  When I fill in the following:
    | Username          | mislav                      |
    | First name        | Mislav                      |
    | Last name         | Marohnić                    |
    | Email             | mislav@fuckingawesome.com   |
    | Password          | makeabarrier                |
    | Confirm password  | makeabarrier                |
    And I press "Create account"
  Then I should see "Confirm your email"
    And "mislav@fuckingawesome.com" should receive 1 email

  When I open the email
  Then I should see "Hey, Mislav Marohnić!" in the email body

  When I follow "Log into Teambox now!" in the email
  Then I should see "Welcome"  