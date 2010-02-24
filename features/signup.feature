Feature: Signing up
  Scenario: Mislav successfully signs up and confirms his email
    When I go to the signup page
    And I fill in the following:
      | Username          | mislav                      |
      | First name        | Mislav                      |
      | Last name         | Marohnić                    |
      | Email             | mislav@fuckingawesome.com   |
      | Password          | makeabarrier                |
      | Confirm password  | makeabarrier                |
      And I select "(GMT+01:00) Amsterdam" from "Time Zone"
      And I press "Create account"
    Then I should see "Confirm your email"
      And "mislav@fuckingawesome.com" should receive an email

    When I open the email
    Then I should see "Hey, Mislav Marohnić!" in the email body

    When I follow "Log into Teambox now!" in the email
    Then I should see "Welcome"

  Scenario Outline: User tries to sign up with a reserved username
    When I go to the signup page
    And I fill in the following:
      | Username          | <username>                  |
      | First name        | Al                          |
      | Last name         | Lane                        |
      | Email             | al.lane@example.com         |
      | Password          | makeabarrier                |
      | Confirm password  | makeabarrier                |
    And I press "Create account"
   Then I should see "is reserved"
    And "al.lane@example.com" should receive no emails
    Examples:
    | username |
    | all      |
    | ALL      |