Feature: Send email to users mentioned in comments
  In order to faciliate communication between users
  As a Teambox admin
  I want users be sent emails whenever their login is mentioned in comments

  Background: 
    Given the following confirmed users exist
      | login  | email                    | first_name | last_name | locale   |
      | balint | balint.erdi@gmail.com    | Balint     | Erdi      | it       |
      | pablo  | pablo@teambox.com        | Pablo      | Villalba  | es       |
      | james  | james.urquhart@gmail.com | James      | Urquhart  | en       |

  Scenario: Mention several users
    Given a project exists with name: "Surpass Basecamp"
    And all the users are in the project with name: "Surpass Basecamp"
    When I am logged in as balint
    And I go to the page of the "Surpass Basecamp" project
    And I fill in "comment_body" with "@pablo @james Check this out!"
    And I press "Pubblica"
    And I wait for 1 second
    Then "pablo@teambox.com" should receive an email with subject "surpass-basecamp"
    When "pablo@teambox.com" opens the email with subject "surpass-basecamp"
    Then he should see "Conversación" in the email body
    And "james.urquhart@gmail.com" should receive an email with subject "surpass-basecamp"
    When "james.urquhart@gmail.com" opens the email with subject "surpass-basecamp"
    Then he should see "Conversation:" in the email body

  Scenario: Mention all users by using @all in a project comment
    Given a project exists with name: "Surpass Basecamp"
    And all the users are in the project with name: "Surpass Basecamp"
    And I am logged in as balint
    And I go to the page of the "Surpass Basecamp" project
    And I fill in "comment_body" with "@all Check this out!"
    And I press "Pubblica"
    And I wait for 1 second
    Then "pablo@teambox.com" should receive an email with subject "surpass-basecamp"
    When "pablo@teambox.com" opens the email with subject "surpass-basecamp"
    Then he should see "Conversación:" in the email body
    And "james.urquhart@gmail.com" should receive an email with subject "surpass-basecamp"
    When "james.urquhart@gmail.com" opens the email with subject "surpass-basecamp"
    Then he should see "Conversation" in the email body

  Scenario: Mention all users by using @all in a task comment
    Given a project exists with name: "Surpass Basecamp"
    And all the users are in the project with name: "Surpass Basecamp"
    And the task list called "Urgent" belongs to the project called "Surpass Basecamp"
    And the following task with associations exist:
      | name     | task_list | project          |
      | Lure DHH | Urgent    | Surpass Basecamp |
    And I am logged in as balint
    When I go to the page of the "Lure DHH" task
    And I fill in "comment_body" with "@all That would be cool!"
    And I press "Pubblica"
    Then I should see "James Urquhart"
    And I should see "Pablo Villalba"
    Then "pablo@teambox.com" should receive an email with subject "surpass-basecamp"
    And "james.urquhart@gmail.com" should receive an email with subject "surpass-basecamp"

  Scenario: Mention all users by using @all in a conversation comment
    Given a project exists with name: "Surpass Basecamp"
    And all the users are in the project with name: "Surpass Basecamp"
    And the following conversation with associations exist:
      | name               | project          | user   |
      | Long-term strategy | Surpass Basecamp | balint |
    And I am logged in as balint
    When I go to the page of the "Long-term strategy" conversation
    And I fill in "comment_body" with "@all Think outside of the box!"
    And I press "Pubblica"
    And I wait for 3 seconds
    Then "pablo@teambox.com" should receive an email with subject "surpass-basecamp"
    And "james.urquhart@gmail.com" should receive an email with subject "surpass-basecamp"
    When I go to the page of the "Long-term strategy" conversation  #FIXME: this should not be needed, it should display the new followers right away (probably a watchings_ids caching issue)
    Then I should see "James Urquhart"
    And I should see "Pablo Villalba"

