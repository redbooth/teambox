Feature: Public projects

  Scenario: User visits a non-public project
    Given I am currently in the project ruby_rockstars
    And I go to the public project page
    Then I should see "Not a public project"

  Scenario: User visits a public project
    Given I am currently in the project procial_network
    And I go to the public project page
    Then I should see "Procial Network"
    Then I should not see "Not a public project"
    Then I should see "Join the project"
    And I should see "Join this group"
    And I should see "Other public projects..."
    When I follow "All Conversations"
    Then I should see "Conversations in this community"
    And I should see "+ Log into Teambox to create a new conversation"
