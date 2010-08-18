@javascript
Feature: Preview

  Background:
    Given a project exists with name: "Ruby Rockstars"
    And I am logged in as mislav
    And I am in the project called "Ruby Rockstars"

  Scenario: I compose a comment with line breaks
    When I go to the page of the "Ruby Rockstars" project
    And I fill in "comment_body" with line breaks
    And I press "Preview"
    Then I should see "Text with<br />a break" within ".previewBox"

  Scenario: I compose a comment with underscored words, links and emails
    When I go to the page of the "Ruby Rockstars" project
    And I fill in "comment_body" with "Text _with_ an underscored_long_word and  a link like this one: http://teambox.com or an email like jordi@teambox.com"
    And I press "Preview"
    Then I should see "<em>Text</em> with an underscored_long_word" within ".previewBox"
    And I should see "http://teambox.com" within ".previewBox a"
    And I should see "jordi@teambox.com" within ".previewBox a"
