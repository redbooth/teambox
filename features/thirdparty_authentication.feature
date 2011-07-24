Feature: Authentication with third party service

  Scenario Outline: The user can link their account with third party and login
    Given @charles exists and is logged in
    And I go to the projects page
    When I authenticate on "<service>" with "Charles" account
    Then I should see "Your account has been linked."
    And I log out
    And I authenticate on "<service>" with "Charles" account
    Then I should see "Logged in successfully"

    Examples:
      | service  |
      | Github   |
      | Twitter  |
      | Google   |
      | Facebook |
      | LinkedIn |

  Scenario: An other user try to link an account that is already linked with another user
    Given @charles exists and is logged in
    And I go to the projects page
    When I authenticate on "Twitter" with "Charles" account
    Then I should see "Your account has been linked."
    And @jordi exists and is logged in
    And I authenticate on "Twitter" with "Charles" account
    Then I should see 'This service is already linked to another account on the system.'
    And I authenticate on "Twitter" with "Jordi" account
    Then I should see "Your account has been linked."

  Scenario Outline: The user signup using with a third-party and it should auto-complete the form.
    When I authenticate on "<service>" with "Charles" account
    Then the fields "<fields>" should contain "<values>"

    Examples:
      | service  | fields                                               | values                                      |
      | Github   | user_first_name,user_last_name,user_email,user_login | Charles,Barbier,charles@teambox.com,charles |
      | Twitter  | user_first_name,user_last_name,user_login            | Charles,Barbier,charles                     |
      | Google   | user_email                                           | charles@teambox.com                         |
      | Facebook | user_first_name,user_last_name,user_email,user_login | Charles,Barbier,charles@teambox.com,charles |
      | LinkedIn | user_first_name,user_last_name                       | Charles,Barbier                             |

  Scenario Outline: The user try to signup with a third party account, but he already has a Teambox account, not yet linked
    Given @charles exists
    When I authenticate on "<service>" with "Charles" account
    Then I should see "We already have an account on the system"
    And I go to the login page
    And I fill in "Email or Username" with "charles"
    And I fill in "Password" with "dragons"
    And I press "Log in"
    Then I should see "Your account has been linked."

    Examples:
      | service  |
      | Github   |
      | Twitter  |
      | Facebook |

  Scenario: The user don't complete signup with a third-party and login to link is account.
    Given @charles exists
    When I authenticate on "Twitter" with "Charles" account
    Then I should see "We already have an account on the system"
    Then I go to the logout page
    Then I am logged in as @charles
    When I authenticate on "Twitter" with "Charles" account
    Then I should not see 'This service is already linked to another account on the system.'
    And I should see "Your account has been linked."