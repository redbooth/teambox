Feature: Send email to users mentioned in comments
  In order to faciliate communication between users
  As a Teambox admin
  I want users be sent emails whenever their login is mentioned in comments

  Background:
    Given the following confirmed users exist
      | login  | email                     | first_name | last_name | language |
      | balint | balint.erdi@gmail.com     | Balint     | Erdi      | it       |
      | pablo  | pablo@teambox.com         | Pablo      | Villalba  | es       |
      | james  | james.urquhart@gmail.com  | James      | Urquhart  | en       |

  Scenario: Mention several users in one comment
  Given a project exists with name: "Surpass Basecamp"
  And all the users are in the project with name: "Surpass Basecamp"
  When I am logged in as "balint"
  And I go to the page of the "Surpass Basecamp" project
  And I fill in "comment_body" with "@pablo @james Check this out!"
  And I press "Pubblica"
  And I wait for 1 second
  Then "pablo@teambox.com" should receive an email with subject "surpass-basecamp"
  When "pablo@teambox.com" opens the email with subject "surpass-basecamp"
  Then he should see "Comentario en la pared del proyecto" in the email body
  And "james.urquhart@gmail.com" should receive an email with subject "surpass-basecamp"
  When "james.urquhart@gmail.com" opens the email with subject "surpass-basecamp"
  Then he should see "Comment on project's wall" in the email body

