Feature: Edit user settings
  In order to save a ton of time
  As a Teambox admin
  I want users to edit their own settings

  Background: 
    Given there is a user called "balint"
    And the user called "balint" is confirmed

  Scenario: User changes time zone
    Given I am logged in as balint
    When I go to my settings page
    And I select "(GMT+01:00) Budapest" from "Time Zone"
    And I press "Update account"
    Then I should see "User profile updated!"
    And I should see "(GMT+01:00) Budapest"

  Scenario: Failed because of bad login
    Given I am logged in as balint
    When I go to my settings page
    And I fill in "Username" with "balint.erdi"
    And I press "Update account"
    Then I should see an error message: "Couldn't save the updated profile. Please correct the mistakes and retry."

  Scenario Outline: User tries to update his login to a reserved one
    Given I am logged in as balint
    When I go to my settings page
    And I fill in "Username" with "<username>"
    And I press "Update account"
    Then I should see an error message: "Couldn't save the updated profile. Please correct the mistakes and retry."

    Examples: 
      | username |
      | all      |
      | ALL      |

