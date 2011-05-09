@javascript
Feature: All the Javascript specs run correctly

  Scenario: Running the datetime specs
    When I run the datetime javascript specs
    Then I should see all specs passing

  Scenario: Running the tasks specs
    When I run the tasks javascript specs
    Then I should see all specs passing

