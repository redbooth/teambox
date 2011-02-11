@javascript
Feature: Posting a comment on a project wall

  Background: 
    Given a project with user @mislav
    And I am logged in as @mislav
    When I go to the project page

  Scenario Outline: I post a comment to the project wall
    When I fill in the comment box with "<body>"
    And I press "Save"
    And I wait for 1 second
    Then I should see '<formatted_body>'

    Examples: 
      | body                                | formatted_body                  |
      | She *used* to _mean_ so much to ME! | She used to mean so much to ME! |
      | Hey, @geoffrey!                     | Hey, @geoffrey!                 |

  Scenario: I post an empty comment to the projects wall
    When I fill in the comment box with ""
    And I press "Save"
    And I wait for 1 second
    Then I should see 'The conversation cannot start with an empty comment.'

  Scenario: I compose a comment with line breaks
    When I fill in the comment box with line breaks
    And I wait for 1 second
    Then I should see "Text with<br>a break" in the preview

  Scenario: I compose a comment with underscored words, links and emails
    When I fill in the comment box with underscored words and links
    And I wait for 1 second
    Then I should see "<em>Text</em> with an underscored_long_word" in the preview
    And I should see "http://teambox.com" in the preview
    And I should see "jordi@teambox.com" in the preview
