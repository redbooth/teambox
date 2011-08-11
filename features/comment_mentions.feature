Feature: Notifications of comment mentions
  In order to not miss any of the discussions important to me
  As a Teambox user
  I want to be notified when I'm mentioned

  Background: 
    Given a project with users @balint, @saimon, @pablo, @charles, @jordi and @james
    And @balint has his locale set to Italian
    And @pablo has his locale set to Spanish
    And @charles has his locale set to French
    And @jordi has his locale set to Catalan
    And @saimon wants to watch new conversations

  Scenario: Mention several users
    Given I am logged in as @balint
    When I go to the project page
    And I fill in the comment box with "Hey, check this out @jordi, @pablo and @james!"
    And I press "Salva"
    Then @pablo and @james should receive an email
    And @balint and @charles should receive no emails
    When @pablo opens the email
    Then he should see "Conversación:" in the email body
    When @jordi opens the email
    Then he should see "Conversa:" in the email body
    When @james opens the email
    Then he should see "Conversation:" in the email body
    And @saimon should receive an email

  Scenario: Mention all users by using @all in conversation
    Given I am logged in as @balint
    When I go to the project page
    And I fill in the comment box with "Hey @all, check this out!"
    And I press "Salva"
    Then @pablo, @charles, @jordi and @james should receive an email

  Scenario: Mention all users by using @all in task
    Given I am logged in as @james
    And I have a task called "Awesome stuff"
    When  I go to the project page
    And I follow "Awesome stuff"
    And I fill in the comment box with "Hey @all, check this out!"
    And I press "Save"
    Then @pablo, @charles, @jordi and @balint should receive an email

  Scenario: User turns off notifications
    Given I am logged in as @james
    When I go to the account settings page
    And I follow "Notifications"
    And I uncheck "Notify me of updates to conversations I'm watching"
    And I press "Update account"

    Given I am logged in as @balint
    When I go to the project page
    And I fill in the comment box with "Hey @all, check this out!"
    And I press "Salva"
    Then @pablo, @charles and @jordi should receive an email
    And @james should receive no emails

  Scenario: Create simple conversation when already watching new conversations
    Given @pablo wants to watch new conversations
    Given @jordi wants to watch new conversations
    Given I am logged in as @saimon
    When I go to the project page
    And I fill in the comment box with "Hey! Look! No uniqueness exception!"
    And I press "Save"
    Then I should see "Hey! Look! No uniqueness exception!"
    Then @saimon should receive no emails
    Then @pablo and @jordi should receive an email
    And @balint, @charles and @james should receive no emails

