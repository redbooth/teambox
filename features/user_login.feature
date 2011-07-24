@signup
Feature: Logging In

  Background: 
    Given I am currently "mislav"
    And I go to the login page
    And I fill in "Email or Username" with "mislav"
    And I fill in "Password" with "dragons"
    And I press "Log in"

  Scenario: Mislav successfully logs in with a confirmed email
    When I have confirmed my email
    And I go to the home page
    Then I should see "All Projects"

  Scenario: Mislav logs in for the first time and sees the new project primer (he is not impressed)
    When I have confirmed my email
    And I go to the home page
    Then I should see "Create a Project"

  Scenario: Mislav logout and try to login with wrong password and username
    When I log out
    Then I should see "Email or Username"
    And I fill in "Email or Username" with "dragons"
    And I fill in "Password" with "mislav"
    And I press "Log in"
    Then I should see an error message: "Couldn't log you in as dragons"
