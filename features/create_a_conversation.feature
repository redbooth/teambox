Feature Creating a conversation

  Scenario: Mislav creates a valid conversation on his project
    Given I am logged in as mislav
    # All this block should be: And a project exists with name: "ruby_rockstars"
    When I go to the new project page
    And I fill in "Name" with "Ruby Rockstars"
    And I fill in "URL" with "ruby_rockstars"
    And I press "Create project and start inviting people"
    Then I should see "Ruby Rockstars"
    ##
    Then I go to the conversations page
    And I should see "This project doesn't have any conversations yet"
    Then I follow "Create the first conversation in this project"
    And I should see "New Conversation"
    And I fill in "conversation_name" with "Let's code the next big thing"
    And I fill in "conversation_body" with "I'm having some ideas for an upcoming project: *Getting Laid*, the book."
    And I press "Create"
    Then I should see "Let's code the next big thing"
    And I should see "I’m having some ideas for an upcoming project: Getting Laid, the book."
    And I should see "People watching:"
    And I should see "Mislav Marohnić"
    And I should see "Unwatch"
    Then I fill in "comment_body" with "A better, saucier and faster way of getting laid"
    And I press "Comment"
    # this response is ajax and should be tested
    Then I go to the conversations page
    And I follow "Let's code the next big thing"
    ##
    Then I should see "I’m having some ideas for an upcoming project: Getting Laid, the book."
    And I should see "A better, saucier and faster way of getting laid"
