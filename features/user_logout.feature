Feature: Logging Out

  Background: 
    Given @mislav exists and is logged in
    And I go to the home page
    And I follow "Logout"

  Scenario: User successfully logs out and sees the goodbye page
    Then I should see "You're now logged out"
