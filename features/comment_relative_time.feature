@javascript
Feature: Comment have human readable relative date

  Background:
    Given a project with user @mislav
    And I am logged in as @mislav
    And I previously posted the following comments:
      | relative_time  |
      | 1 second ago   |
      | 10 minutes ago |
      | 1 days ago     |

  Scenario: I look at relative time of posted comment
    When I go to the conversations page
    And I follow "Testing date"
    Then I should see the following time representation:
      | formatted_relative_time |
      | now                     |
      | 10 minutes ago          |
      | Yesterday               |
