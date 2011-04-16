Feature: Login with third party service

  Scenario Outline: The user can link their account with third party and login
    Given @charles exists and is logged in
    And I go to the projects page
    When I authenticate with "<service>"
    Then I should see "Your account has been linked."
    And I log out
    And I authenticate with "<service>"
    Then I should see "Logged in successfully"

    Examples:
      | service  |
      | Github   |
      | Twitter  |
      | Google   |
      | Facebook |
      | LinkedIn |
