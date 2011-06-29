@javascript
Feature: Creating a private page

  Background: 
    Given the following confirmed users exist
      | login  | email                    | first_name | last_name |
      | pablo  | pablo@teambox.com        | Pablo      | Villalba  |
      | jordi  | jordi@teambox.com        | Jordi      | Romero    |
      | enric  | enric@teambox.com        | Enric      | Lluelles  |
    Given a project with users @mislav, @pablo, @jordi and @enric
    And I am logged in as @mislav

  Scenario: All pages are private
	Given @pablo created the private project page "Secret Plans"
    When I go to the pages page
    Then I should not see "Secret Plans"
    When I go to the page named "Secret Plans"
    Then I should not see "Secret Plans"

  Scenario: Private page
    When I go to the pages page
    And I follow "New Page" within ".text_actions"
    And I fill in "Name" with "Location of Cheezburger Factory"
    And I fill in "Description" with "GPS coordinates located within"
    Then the "This element is visible to everybody in this project" checkbox should be checked
    When I choose "This element is only visible to people you specify..."
    And I uncheck "Pablo Villalba"
    And I press "Create"
    Then I should see "Location of Cheezburger Factory"
    And @pablo should receive no emails
    And @mislav should receive no emails
    When I am logged in as @pablo
    When I go to the page named "Location of Cheezburger Factory"
    Then I should not see "Location of Cheezburger Factory"

  Scenario: Managing people in a private page
    Given @mislav created the private project page "Lolcat Candidates"
    When I go to the page named "Lolcat Candidates"
    And I follow "Edit"
    Then the "This element is only visible to people you specify..." checkbox should be checked
    When I choose "This element is only visible to people you specify..."
    And I uncheck "Jordi Romero"
    And I check "Pablo Villalba"
    And I press "Update"
    Given I am logged in as @jordi
    When I go to the page named "Lolcat Candidates"
    Then I should not see "Lolcat Candidates"
    Given I am logged in as @pablo
    When I go to the page named "Lolcat Candidates"
    Then I should see "Lolcat Candidates"
    When I follow "Edit"
    Then I should see "This element is only visible to the following people..."
    Given I am logged in as @mislav
    When I go to the page named "Lolcat Candidates"
    And I follow "Edit"
    Then the "This element is only visible to people you specify..." checkbox should be checked
    When I choose "This element is only visible to people you specify..."
    And I uncheck "Pablo Villalba"
    And I press "Update"
    Given I am logged in as @pablo
    When I go to the page named "Lolcat Candidates"
    Then I should not see "Lolcat Candidates"

  Scenario: Private pages can only be modified by the creator
    Given @mislav created the private project page "Lolcat Report"
    And the page "Lolcat Report" is watched by @pablo
    When I go to the page named "Lolcat Report"
    And I follow "Edit"
    Then I should see "This element is only visible to people you specify..."
    Given I am logged in as @pablo
    When I go to the page named "Lolcat Report"
    And I follow "Edit"
    Then I should see "This element is only visible to the following people..."

  Scenario: Making a private page public
    Given @mislav created the private project page "Controversial Lolport"
    When I go to the page named "Controversial Lolport"
    And I follow "Edit"
    Then the "This element is only visible to people you specify..." checkbox should be checked
    When I choose "This element is visible to everybody in this project"
    And I press "Update"
    Given I am logged in as @pablo
    When I go to the pages page
    Then I should see "Controversial Lolport"


