@wip
Feature Transfer Project
  Background:	
       Given the following confirmed users exist
         | login  | email                     | first_name | last_name |
         | balint | balint.erdi@gmail.com     | Balint     | Erdi      |
         | pablo  | pablo@teambox.com         | Pablo      | Villalba  |
         | james  | james.urquhart@gmail.com  | James      | Urquhart  |
       Given I am logged in as mislav
         And I am currently in the project ruby_rockstars
         And I go to project settings path
       Given "balint" is in the project called "Ruby Rockstars"
         And "pablo" is not in the project called "Ruby Rockstars"

    Scenario: Mislav transfers a project
       Then the user called "balint" should not administrate the project called "Ruby Rockstars"
       Given I follow "Ownership"
         And I should see "Ownership" within "h2"
        When I select "Balint Erdi" from "Owner"
         And I press "Change owner"
        Then I should see "Project ownership has been transferred." within ".flash_box div"
       Given I go to project settings path
        Then I should not see "Ownership"
       Then the user called "balint" should administrate the project called "Ruby Rockstars"
       

