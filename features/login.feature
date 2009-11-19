Feature: Logging In

  Scenario: Mislav successfully logs in with a confirmed email
    Given I login as mislav
    And I have confirmed my email
    When I go to the home page    
    Then I should see "All Projects"
    
  Scenario: Mislav fails to log in because he didn't confirmed his email
    Given I login as mislav
    And I have never confirmed my email
    When I go to the home page    
    Then I should see "Confirm your email"

  Scenario: Mislav logs in for the first time and sees the welcome tab (he's not impressed)
    Given I login as mislav
    And I have confirmed my email
    And It is my first time logging in
    When I go to the home page
    Then I should see "Welcome"
