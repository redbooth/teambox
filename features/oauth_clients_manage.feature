@javascript
Feature: Managing OAuth clients and tokens
  Background:
    Given @mislav exists and is logged in

  Scenario: I manage an application
    When I go to the your apps page
    And I follow "Register a new app"
    Then I should see "Register a new application"
    When I fill in the following:
      | Name                    | Pithub Services             |
      | Client URL              | http://www.pithub.com       |
      | Callback URI            | https://www.pithub.com/auth |
      | Support URL             | http://support.pithub.com   |
    And I press "Register application"
    Then I should see "Pithub Services"
    When I follow "Edit"
    Then I should see "Pithub Services"
    And I follow "Delete" confirming with OK
    Then I should not see "Pithub Services"

  Scenario: I have no access tokens
    When I go to the your linked apps page
    Then I should see "No applications are authorized to access your Teambox account."

  Scenario: I revoke an access token
    Given I have an OAuth access token
    When I go to the your linked apps page
    Then I should see "The following applications are authorized to access your Teambox account."
    And I should see "Cucumber.ly"
    When I follow "Revoke" confirming with OK
    When I go to the your linked apps page
    And I should see "No applications are authorized to access your Teambox account."
    And I should not see "Cucumber.ly"
