Feature Creating a conversation
  Background:
    Given I am logged in as mislav
      And I am currently in the project ruby_rockstars
    
  Scenario: Mislav sees there are no conversations yet
    When I go to the conversations page
    Then I should see "This project doesn't have any conversations yet"

  Scenario: Mislav creates a valid conversation on his project
    When I go to the conversations page
      And I follow "Create the first conversation in this project"
    Then I should see "New Conversation"

    When I fill in the following:
      | conversation_name | Lets code the next big thing                                            |
      | conversation_body | Im having some ideas for an upcoming project: *Getting Laid*, the book. |
      And I press "Create"
    Then I should see "Lets code the next big thing"
      And I should see "Im having some ideas for an upcoming project: Getting Laid, the book."
      And I should see "People watching:"
      And I should see "Mislav Marohnić"
      And I should see "Unwatch"

    When I fill in "comment_body" with "A better, saucier and faster way of getting laid"
      And I press "Comment"
    # this response is ajax and should be tested
    Then I go to the conversations page
      And I follow "Lets code the next big thing"
    ##
    Then I should see "Im having some ideas for an upcoming project: Getting Laid, the book."
      And I should see "A better, saucier and faster way of getting laid"
