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

  Scenario: User visits a public project with private elements
    Given @mislav exists and is logged in
    Given the following confirmed users exist
      | login  | email                    | first_name | last_name |
      | pablo  | pablo@teambox.com        | Pablo      | Villalba  |
      | jordi  | jordi@teambox.com        | Jordi      | Romero    |
    And @pablo is currently in the project procial_network
    And @jordi is currently in the project procial_network
    Given I am currently in the project procial_network
    Given @pablo started a private conversation named "Lolcat discussion"
    And @jordi started a conversation named "We are seriously procial"
    And @jordi created a private task named "Hire lolcats" in the task list called "Lolbox"
    And I go to the public project page
    Then I should see "Procial Network"
    And I should not see "Lolcat discussion"
    And I should not see "Hire lolcats"
    When I go to the public project page for the "Lolcat discussion" conversation
    Then I should not see "Lolcat discussion"
    When I go to the public project page for the "We are seriously procial" conversation
    Then I should see "We are seriously procial"