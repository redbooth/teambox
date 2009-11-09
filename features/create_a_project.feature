Feature Creating a project

  Scenario: Creating a project
    Given I am logged in as mislav
    When I go to the new project page
    And I should see "a" tag with "Add Project"

    #And I fill in "Name" with "Ruby Rockstars"
    #And I fill in "Permalink" with "ruby_rockstars"
    #And I press "Create project and start inviting people"
    #Then I should see a new tab for "Ruby Rockstars"
