@apidoc
Feature: Looking at the api docs

  Scenario: Mislav doesn't get to read his favourite apidocs
    Given the database is empty
    When I go to the apidocs page
    Then I should see "In order to view the api documentation, you must first configure your app and build an organization."

  Scenario: Mislav gets to read his favourite apidocs
    Given the database is empty
    Given I am logged in as mislav
    And I am currently in the project ruby_rockstars
    And I am an administrator in the organization called "ACME"
    When I go to the apidocs page
    Then I should see "API documentation"
    And "example_api_user" should belong to the organization "API Corp" as an admin
