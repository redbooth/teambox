Feature: Logging In
  Background:
    Given I am logged in as mislav
    
  Scenario: Mislav successfully logs in with a confirmed email
     Given I have confirmed my email
      When I go to the home page    
      Then I should see "All Projects"
    
  Scenario: Mislav fails to log in because he did not confirm his email
     Given I have never confirmed my email
      When I go to the home page    
      Then I should see "Confirm your email"

  Scenario: Mislav logs in for the first time and sees the welcome tab (he is not impressed)
    Given I have confirmed my email
      And It is my first time logging in
     When I go to the home page
     Then I should see "Welcome"
