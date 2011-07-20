Feature: Email Spec in Rails 3 App

In order to prevent me from shipping a defective email_spec gem
As a email_spec dev
I want to verify that the example rails 3 app runs all of it's features as expected

  Scenario: generators test
    Given the rails3 app is setup with the latest generators
    When I run "rails g email_spec:steps >/dev/null" in the rails3 app
    Then the rails3 app should have the email steps in place

  Scenario: regression test
    Given the rails3 app is setup with the latest email steps
    When I run "rake db:migrate RAILS_ENV=test >/dev/null" in the rails3 app
    And I run "cucumber features -q --no-color 2>/dev/null" in the rails3 app
    Then I should see the following summary report:
    """
    13 scenarios (5 failed, 8 passed)
    110 steps (5 failed, 1 skipped, 104 passed)
    """
