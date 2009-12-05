Feature Posting a comment on a project wall
  Background:
    Given I am logged in as mislav
      And I am currently in the project ruby_rockstars

  Scenario Outline: I post a comment to the project wall
    Given I go to the project page
      And I fill in "comment_body" with "<body>"
    # Using format.html which redirects, not .js
    When I press "Comment"
    Then I should see "<formatted_body>"

  Examples:
    | body                                | formatted_body                  |
    | She *used* to _mean_ so much to ME! | She used to mean so much to ME! |
    | Hey, @geoffrey!                     | Hey, @geoffrey!                 |
