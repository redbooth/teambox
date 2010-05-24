Feature: Posting a comment on a project wall
  Background:
    Given a project exists with name: "Ruby Rockstars"
    And I am logged in as "mislav"
    And I am in the project called "Ruby Rockstars"

  Scenario Outline: I post a comment to the project wall
    When I go to the page of the "Ruby Rockstars" project
      And I fill in "comment_body" with "<body>"
      And I press "Save"
      And I wait for 1 second
      Then I should see "<formatted_body>"
  Examples:
    | body                                | formatted_body                  |
    | She *used* to _mean_ so much to ME! | She used to mean so much to ME! |
    | Hey, @geoffrey!                     | Hey, @geoffrey!                 |

  Scenario: I post an empty comment to the projects wall
    When I go to the page of the "Ruby Rockstars" project
      And I fill in "comment_body" with ""
      And I press "Save"
      And I wait for 1 second
      Then I should see "Please write about what you have done in the box above."
