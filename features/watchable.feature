@wip
Feature Watchable Objects
  Background:
    Given the following confirmed users exist
      | login  | email                     | first_name | last_name |
      | balint | balint.erdi@gmail.com     | Balint     | Erdi      |
      | pablo  | pablo@teambox.com         | Pablo      | Villalba  |
      | james  | james.urquhart@gmail.com  | James      | Urquhart  |
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

  Scenario: New conversation
    When I go to the new conversation page
      And I fill in the following:
        | conversation_name | Talk!     |
        | conversation_body | We need to discuss!  |
     And I press "Create"
    Then "balint" should be watching the conversation "Talk!"
    Then "pablo" should be watching the conversation "Talk!"
    Then "james" should be watching the conversation "Talk!"
    When I fill in "comment_body" with "Rockets!"
      And I press "Comment"
    Then "balint.erdi@gmail.com" should receive an email
    Then "pablo@teambox.com" should receive an email
    Then "james.urquhart@gmail.com" should receive an email
    Given "balint" stops watching the conversation "Talk!"
    When I fill in "comment_body" with "Parrots!"
      And I press "Comment"
    Then "balint.erdi@gmail.com" should receive no emails
      And "balint" should not be watching the conversation "Talk!"
    Then "pablo@teambox.com" should receive an email
    Then "james.urquhart@gmail.com" should receive an email
    Given "pablo" is not in the project called "Ruby Rockstars"
    When I fill in "comment_body" with "Squark!"
      And I press "Comment"
    Then "pablo@teambox.com" should not receive an email
      And "pablo" should not be watching the conversation "Talk!"

  Scenario: Existing conversation
    When I go to the conversations page
      And I follow "Politics"
    Then "balint" should be watching the conversation "Politics"
    Then "pablo" should be watching the conversation "Politics"
    Then "james" should be watching the conversation "Politics"
    When I fill in "comment_body" with "Senators!"
      And I press "Comment"
    Then "balint.erdi@gmail.com" should receive an email
    Then "pablo@teambox.com" should receive an email
    Then "james.urquhart@gmail.com" should receive an email
    Given "balint" stops watching the conversation "Politics"
    When I fill in "comment_body" with "Celebrities!"
      And I press "Comment"
    Then "balint.erdi@gmail.com" should not receive an email
      And "balint" should not be watching the conversation "Politics"
    Then "pablo@teambox.com" should receive an email
    Then "james.urquhart@gmail.com" should receive an email
    Given "pablo" is not in the project called "Ruby Rockstars"
    When I fill in "comment_body" with "Scandal!"
      And I press "Comment"
    Then "pablo@teambox.com" should receive no emails
      And "pablo" should not be watching the conversation "Politics"

