@wip
Feature Update a profile
  Background:
    Given I am logged in as mislav
      And I am on the account settings page

  Scenario: Mislav updates his profile
    Given I follow "Profile Information"
      And I should see "Your Profile Settings" within "h2"
     When I fill in the following:
         | First name        | Mis                      |
         | Last name         | Mar                      |
         | Biography         | Ruby Rockstar Programmer |
      And I press "Update account"
     Then I should see "User profile updated!" within ".flash_success div"
      And I follow "mislav"
     Then I should see "Mis Mar" within ".banner h2"
      And I should see "Ruby Rockstar Programmer" within ".biography"

  Scenario: Mislav updates his profile picture
    Given I follow "Profile Picture"
      And I should see "Your Profile Picture" within "h2"
      And I attach the file at "features/support/sample_files/dragon.jpg" to "user_avatar"
      And I press "Update account"    
     Then I should not see missing avatar image within ".column"
  
  Scenario: Mislav fails to update his profile picture with blank
  Scenario: Mislav fails to update his profile picture because its too big     
  Scenario: Mislav updates his notifications
  Given I follow "Notifications"
    And I should see "Your Notifications"
   When I check "user_notify_mentions"
   When I uncheck "user_notify_conversations"
   When I check "user_notify_task_lists"
   When I check "user_notify_tasks"
   When I check "Notify me daily of tasks assigned to me"
    And I press "Update account"
   Then I should see "User profile updated!" within ".flash_success"
     And I follow "Notifications"
     And I should see "Your Notifications" 
    And the "Notify me when I'm mentioned eg. Howdy @mislav! You'll receive an email!" checkbox should be checked
    And the "Notify me when I'm watching a conversation" checkbox should not be checked
    And the "Notify me when I'm watching a task list" checkbox should be checked
    And the "Notify me when I'm watching a task" checkbox should be checked
    And the "Notify me daily of tasks assigned to me" checkbox should be checked

  Scenario: Mislav updates his username
     Given I follow "Account Settings"
       And I should see "Your Account Settings"
      When I fill in "Username" with "mislavrocks"
       And I press "Update account"
      Then I should see "User profile updated!" within ".flash_success"
       And I should see "mislavrocks"
       
  Scenario: Mislav fails to update his username because its already in use
  Scenario: Mislav fails to update his username with invalid format
  
  Scenario: Mislav updates his card profile information
  Given I follow "Profile Information"
    And I should see "Your Profile Settings" within "h2"
   When I follow "+ Add Phone Number"
     And I fill in "user_card_attributes_phone_numbers_attributes_1260832025948_name"
  
  
  Scenario: Mislav fails to update his profile information  