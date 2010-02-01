@wip
Feature: Edit user settings
  In order to save a ton of time
  As a Teambox admin
  I want users to edit their own settings

  Background:
    Given there is a user called "balint"
    And the user called "balint" is confirmed
  
  Scenario: Failed because of bad login
    Given I am logged in as "balint"
    When I go to my settings page
    Then show me the page
    And I fill in "Username" with "balint.erdi"
    And I press "Update account"
    Then I should see an error message: "Invalid username"