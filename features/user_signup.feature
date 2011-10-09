@signup @javascript
Feature: Signing up

  Scenario: Mislav successfully signs up and confirms his email
    When I go to the signup page
    And I fill in the following:
      | Username         | mislav                    |
      | First name       | Mislav                    |
      | Last name        | Marohnić                  |
      | Email            | mislav@fuckingawesome.com |
      | Password         | dragons                   |
      | Confirm password | dragons                   |
    And I select "(GMT+01:00) Amsterdam" from "Time Zone"
    And I press "Create account"
    Then I should see "Go to mislav@fuckingawesome.com to confirm your account"
    And "mislav@fuckingawesome.com" should receive an email
    When I open the email
    Then I should see "Hey, Mislav Marohnić!" in the email body
    When I follow "Log into Teambox now!" in the email
    Then I should see "Create a Project"
    And I should not see "confirm your account"

  Scenario Outline: User tries to sign up with a reserved username
    When I go to the signup page
    And I fill in the following:
      | Username         | <username>          |
      | First name       | Al                  |
      | Last name        | Lane                |
      | Email            | al.lane@example.com |
      | Password         | dragons             |
      | Confirm password | dragons             |
    And I press "Create account"
    Then I should see "is reserved"
    And "al.lane@example.com" should receive no emails

    Examples: 
      | username |
      | all      |
      | ALL      |

  Scenario: I try to sign up when I'm already logged in
    Given I am logged in as mislav
    When I go to the signup page
    Then I should see "You already have an account. Log out first to sign up as a different user."

  Scenario: I'm in the system but I didn't confirm my email
    Given I am logged in as mislav
    And I have never confirmed my email
    When I go to the projects page
    And I follow "Resend the instructions"
    And I wait for 2 seconds
    Then I should receive an email
    And I open the email
    When I follow "Log into Teambox now!" in the email
    Then I should see "Welcome"
    And I should not see "confirm your account"

  Scenario: User signs up and creates an organization and project
    When I go to the signup page
    And I fill in the following:
      | Username          | mislav                    |
      | First name        | Mislav                    |
      | Last name         | Marohnić                  |
      | Email             | mislav@fuckingawesome.com |
      | Password          | dragons                   |
      | Confirm password  | dragons                   |
      | Organization name | Le Game                   |
    And I press "Create account"
    Then show me the page
    Then I should see "Invite people to Le Game"

  Scenario: User signs up and gives a short name for an organization
    When I go to the signup page
    And I fill in the following:
      | Username          | mislav                    |
      | First name        | Mislav                    |
      | Last name         | Marohnić                  |
      | Email             | mislav@fuckingawesome.com |
      | Password          | dragons                   |
      | Confirm password  | dragons                   |
      | Organization name | XY                        |
    And I press "Create account"
    Then show me the page
    Then I should see "Invite people to XY"

