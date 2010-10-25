Feature: Edit password

  Background:
    Given @mislav exists and is logged in
    And His password is "cookies"
    When I go to the account settings page
    And  I follow "Change password"
    And  I fill in the following:
         | Password         | chunky_bacon |
         | Confirm password | chunky_bacon |

  Scenario: User tries to change his password without providing the old one
    When I press "Update account"
    Then I should see "Couldn't save the updated profile"
    And  I should see "Old password is required"

  Scenario: User tries to change his password providing a wrong old password
    And I fill in "Old password" with "waffles"
    And  I press "Update account"
    Then I should see "Couldn't save the updated profile"
    And  I should see "Old password is required"

  Scenario: User tries to change his password providing the old password
    And I fill in "Old password" with "cookies"
    And  I press "Update account"
    Then I should see "User profile updated!"
