Feature: Creating a project
  Background:
    Given I am logged in as mislav
      And I go to the new project page

  Scenario Outline: Mislav creates two valid projects and fails to create an invalid project
    When I fill in the following:
      | Name      | <name> |
      | Permalink | <url>  |
      And I press "Create project and start inviting people"
    Then I should see "<response>"
    And I should see "<flash>"

    Examples:
      | name                      | url             | response          | flash                           |
      | Title with ()_+&-         |                 | Title with ()_+&- | Your project has been created!  |
      | Ruby Rockstars            | ruby_rockstars  | Ruby Rockstars    | Your project has been created!  |
      | Fucking awesome group     | @XFla$@$*       | Invalid project   | Invalid project                 |
