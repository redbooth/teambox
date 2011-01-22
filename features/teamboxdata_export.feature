Feature: Exporting data

  Background: 
    Given a project exists with name: "Ruby Rockstars"
    And @mislav exists and is logged in
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

  Scenario: Mislav attemps to export someone elses magic project he participates in
    Given a project exists with name: "Python Rockstars"
    And I am a participant in the organization of the project called "Python Rockstars"
    When I go to the your data page
    When I follow "Export"
    Then I should not see "Python Rockstars"
