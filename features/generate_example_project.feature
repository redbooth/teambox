Feature Creating an example project
  In order to learn how to use Teambox
  As a logged in user
  I will create an example project

  Background:
    Given I am logged in as mislav

  Scenario: Mislav is in the create an example project page
    When I go to the create an example project page
    Then I should see "Learn by example"

  Scenario: Mislav creates an example project
    When I go to the create an example project page
    And I follow "Create an example project!"
    Then I should see "John Galt Line"
    And I should see "Dagny Taggart" within ".people_list"
    And I should see "Hank Rearden" within ".people_list"
    And I should see "Ellis Wyatt" within ".people_list"
    And I should see "Hey guys, I’m setting up a project on Teambox to build the John Galt line. Hope it helps!"
    And I should see "I’m going to invite Mislav Marohnić to the project, too"
    And "dagny@teambox.com" should receive 0 emails
    And "hank@teambox.com" should receive 0 emails
    And "ellis@teambox.com" should receive 0 emails
    And "mislav@fuckingawesome.com" should receive 0 emails
    
  # Scenario: Mislav already has an example project
  
