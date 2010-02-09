Feature: Send email to users mentioned in comments
  In order to faciliate communication between users
  As a Teambox admin
  I want users be sent emails whenever their login is mentioned in comments

  Background:
    Given the following confirmed users exist
      | login  | email                     | first_name | last_name |
      | balint | balint.erdi@gmail.com     | Balint     | Erdi      |
      | pablo  | pablo@teambox.com         | Pablo      | Villalba  |
      | james  | james.urquhart@gmail.com  | James      | Urquhart  |


  Scenario: Mention several users in one comment
  Given a project exists with name: "Surpass Basecamp"
  And all the users are in the project with name: "Surpass Basecamp"
  When I am logged in as "balint"
  And I go to the page of the "Surpass Basecamp" project
  And I fill in "comment_body" with "@pablo @james Check this out!"
  And I press "Comment"
  And I wait for 3 seconds
  Then "pablo@teambox.com" should receive an email with subject "surpass-basecamp"
  And "james.urquhart@gmail.com" should receive an email with subject "surpass-basecamp"
