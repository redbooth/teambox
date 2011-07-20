@javascript
Feature: Converting a conversation to a task

  Background: 
    Given a project with user @mislav
    And I am logged in as @mislav

  Scenario: Converting a normal conversation on the conversation page
    Given I started a conversation named "Politics"
    When I go to the page of the "Politics" conversation
    And I follow "Convert to task"
    And I wait for 2 seconds
    And I press "Convert"
    And I wait for 1 second
    Then I should see "Politics" in the page title
    And I should see "Politics" in the task thread title

  Scenario: Converting a normal conversation on the overview page
    Given I started a conversation named "Politics"
    When I go to the home page
    And I click the conversation's comment box
    And I follow "Convert to task"
    And I wait for 2 seconds
    And I press "Convert"
    And I wait for 1 second
    Then I should see "Politics" in the task thread title

  Scenario: Converting a normal conversation when you are a commenter
    Given I started a conversation named "Politics"
    And I am a commenter in the project called "Ruby Rockstars"
    When I go to the home page
    And I click the conversation's comment box
    Then I should not see 'Convert to task'

  Scenario: Converting a normal conversation on the overview page and adding a comment
    Given I started a conversation named "Politics"
    When I go to the home page
    And I click the conversation's comment box
    And I fill in the conversation's comment box with "Do this now" within ".thread"
    And I follow "Convert to task"
    And I wait for 2 seconds
    And I fill in "conversation_name" with "An exciting task for you"
    And I press "Convert"
    And I wait for 3 seconds
    Then I should see "An exciting task for you" in the task thread title
    And I should see 'Do this now'

  Scenario: Converting a simple conversation on the overview page without specifying a task name
    Given I started a simple conversation
    When I go to the home page
    And I click the conversation's comment box
    And I follow "Convert to task"
    And I wait for 2 seconds
    And I press "Convert"
    And I wait for 1 second
    Then I should see the error "must not be blank" within ".conversation_actions"

  Scenario: Converting a simple conversation on the overview page specifying the task name
    Given I started a simple conversation
    When I go to the home page
    And I click the conversation's comment box
    And I follow "Convert to task"
    And I wait for 2 seconds
    And I fill in "conversation_name" with "An exciting task for you"
    And I press "Convert"
    And I wait for 1 second
    Then I should see "An exciting task for you" in the task thread title

  Scenario: Converting a simple conversation on the overview page and specifying additional task attributes
    Given the following confirmed users exist
    | login  | email                    | first_name | last_name |
    | pablos | pablo@teambox.com        | Pablo      | Villalba  |
    | saimon | saimon@teambox.com       | Saimon     | Moore     |
    And I am in the project called "Teambox"
    And all the users are in the project with name: "Teambox"
    And the following task lists with associations exist:
      | name         | project |
      | Next release | Teambox |
      | Bugfixes     | Teambox |
    Given I started a simple conversation in the "Teambox" project
    When I go to the page of the "Teambox" project
    And I click the conversation's comment box
    And I follow "Convert to task"
    And I wait for 2 seconds
    And I fill in "conversation_name" with "Give git course"
    And I select "hold" from "conversation_status"
    And I select "Saimon Moore" from "conversation_assigned_id"
    Then I click on the date selector
    And I select the month of "December" with the conversation date picker
    And I select the year "2010" with the conversation date picker
    And I select the day "29" with the date picker
    When I press "Convert"
    And I wait for 1 second
    Then I should see "Give git course" in the task thread title
    And I should see 'new → hold'
    And I should see 'Dec 29' within 'span.assigned_date'
    And I should see 'Assigned to Saimon Moore' within 'p.assigned_transition'


