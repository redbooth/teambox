@wip
Feature Projects Dropdown
 Background:
   Given I am logged in as mislav
    And I am currently in the project ruby_rockstars
 
 Scenario: visible on projects
   Given I go to the home page
    Then I should see "Ruby Rockstars" within "#projects_tab_list li a"

 Scenario: visible in project
   Given I go to the project page
    Then I should see "Ruby Rockstars" within "#projects_tab_list li a"

