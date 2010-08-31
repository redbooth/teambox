Feature: Watchable Objects

  Background: 
    Given the following confirmed users exist
      | login  | email                    | first_name | last_name |
      | balint | balint.erdi@gmail.com    | Balint     | Erdi      |
      | pablo  | pablo@teambox.com        | Pablo      | Villalba  |
      | james  | james.urquhart@gmail.com | James      | Urquhart  |
    Given I am logged in as mislav
    And I am currently in the project ruby_rockstars
    Given "balint" is in the project called "Ruby Rockstars"
    And "pablo" is in the project called "Ruby Rockstars"
    And "james" is in the project called "Ruby Rockstars"
    Given the following conversations exist in the project "Ruby Rockstars" owned by mislav
      | name     | body     |
      | Politics | Discuss! |
    Given "balint" is watching the conversation "Politics"
    Given "pablo" is watching the conversation "Politics"
    Given "james" is watching the conversation "Politics"

  Scenario: New conversation watchers
    When I go to the new conversation page
    And I fill in "Title" with "Talk!"
    And I fill in the comment box with "We need to discuss!"
    And I press "Create"
    Then "balint" should be watching the conversation "Talk!"
    Then "pablo" should be watching the conversation "Talk!"
    Then "james" should be watching the conversation "Talk!"
    When I fill in the comment box with "Rockets!"
    And I press "Save"
    Then "balint.erdi@gmail.com" should receive 2 emails
    Then "pablo@teambox.com" should receive 2 emails
    Then "james.urquhart@gmail.com" should receive 2 emails

  Scenario: Existing conversation with modified watchers
    Given "balint" stops watching the conversation "Politics"
    When I go to the conversations page
    And I follow "Politics"
    When I fill in the comment box with "Senators!"
    And I press "Save"
    When I fill in the comment box with "Rockets!"
    And I press "Save"
    Then "balint.erdi@gmail.com" should receive no emails
    Then "pablo@teambox.com" should receive 2 emails
    Then "james.urquhart@gmail.com" should receive 2 emails

  Scenario: User leaves project
    Given "pablo" is not in the project called "Ruby Rockstars"
    When I go to the conversations page
    And I follow "Politics"
    When I fill in the comment box with "Celebrities!"
    And I press "Save"
    When I fill in the comment box with "Controversy!"
    And I press "Save"
    Then "balint.erdi@gmail.com" should receive 2 emails
    Then "pablo@teambox.com" should receive no emails
    Then "james.urquhart@gmail.com" should receive 2 emails

