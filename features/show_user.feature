Feature: Showing users
  Background:
     Given the following confirmed users exist
       | login  | email                     | first_name | last_name |
       | balint | balint.erdi@gmail.com     | Balint     | Erdi      |
       | pablo  | pablo@teambox.com         | Pablo      | Villalba  |
     Given I am logged in as mislav
       And I am currently in the project ruby_rockstars
       And I go to project settings path
     Given "balint" is in the project called "Ruby Rockstars"
       And "pablo" is not in the project called "Ruby Rockstars"

  Scenario: Mislav should only see the profile of users in the project
    Given I go to the profile of "pablo"
      Then I should not see "Recent activity for Pablo Villalba"
    Given I go to the profile of "balint"
      Then I should see "Recent activity for Balint Erdi"
    Given I go to the profile of "mislav"
      Then I should see "@mislav"

  Scenario: Pablo should only see the profile of users in the project
    Given I log out
      And I am logged in as "pablo"
    Given I go to the profile of "pablo"
      Then I should see "Recent activity for Pablo Villalba"
    Given I go to the profile of "balint"
      Then I should not see "Recent activity for Balint Erdi"
    Given "pablo" is in the project called "Ruby Rockstars"
    Given I go to the profile of "balint"
      Then I should see "Recent activity for Balint Erdi"


