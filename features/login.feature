Feature: Logging In

  Scenario: A user with a confirmed email
    Given I login as mislav
    #And I have confirmed my email
    When I go to the home page    
    Then I should see "All Projects"
    
  #Scenario: A user with a unconfirmed email
  #  Given I login as mislav
  #  And I have never confirmed my email
  #  When I go to the home page    
  #  Then show me the page
  #  And I should see a new project button
  #
  #Scenario: A user logs in for the first time and sees the welcome tab
  #  Given I login as mislav
  #  And I have never logged in before
  #  When I go to the home page    
  #  Then show me the page
  #  And I should see a new project button    
