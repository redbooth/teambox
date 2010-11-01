Feature: Exporting data

  Background: 
    Given a project exists with name: "Ruby Rockstars"
    And I am logged in as mislav
    And I am in the project called "Ruby Rockstars"
    And I am an administrator in the organization of the project called "Ruby Rockstars"
    And deferred data processing is off

  Scenario: Mislav exports his magic project
    When I go to the your data page
    When I follow "Export"
    And I check "Ruby Rockstars"
    And I press "Export data"
    Then I should see "Projects exported:"
      And I should see "Ruby Rockstars"
      And I should see "Download export"
	  And @mislav should receive an email with subject "Your data is ready for download"
