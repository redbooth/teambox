Feature Creating a conversation

  Scenario: A logged in user creating a valid conversation on my project
    Given I am logged in as mislav
    And a project exists with name: "ruby_rockstars"
#    When I go to the conversations page
#    And I click "new_conversation_link"
#    Then I should see "New conversation"
#    And it will auto focus on the name textfield
#    And I fill in "Name" with "Finish Writing Specs"
#    And I press "Save task"
#    Then I should see a new task list at the top of the task list
#    And it should be selected
#    And the content area show load the comment form with a list of empty tasks