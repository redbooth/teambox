Feature Creating a project

  Scenario: Mislav successfully creates a new project
    Given I am logged in as mislav
    When I go to the new project page
    And I fill in "Name" with "Ruby Rockstars"
    And I fill in "URL" with "ruby_rockstars"
    And I press "Create project and start inviting people"
    Then I should see "Ruby Rockstars"

  Scenario: Mislav fails to create a project
    Given I am logged in as mislav
    When I go to the new project page
    And I fill in "Name" with "Fucking awesome group"
    And I fill in "URL" with "!@#XFla#$@$*"
    And I press "Create project and start inviting people"
    Then I should not see "Fucking awesome group" 