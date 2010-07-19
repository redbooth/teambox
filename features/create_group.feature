Feature: Creating a group

  Background: 
    Given I am logged in as mislav
    And I am currently in the project ruby_rockstars
    And groups are enabled

  Scenario: Mislav sees there are no groups yet
    When I go to the groups page
    Then I should see "Create a group"

  Scenario: Mislav creates his group and invites a person
    When I go to the groups page
    And I follow "Create a group"
    Then I should see "Create group"
    When I fill in the following:
      | group_name      | MislavCorp |
      | group_permalink | mislavcorp |
    And I press "Create"
    Then I should see "MislavCorp"
    And I should see "Invite people to the group"
    And I should see "Add a project"
    And I should see "Mislav Marohnić"
    When I fill in "Username or email" with "pablo@teambox.com"
    And I press "Invite"
    Then "pablo@teambox.com" should receive 1 email
    And I should see "An email was sent to this user, but they still haven't confirmed."
    When I follow "Add a project"
    When I select "Ruby Rockstars" from "group[project_ids][]"
    Then I should see "Ruby Rockstars"

