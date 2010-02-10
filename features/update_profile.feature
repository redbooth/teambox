@wip
Feature Update a profile
  Background:
    Given a confirmed user exists with login: "mislav", first_name: "Mislav", last_name: "Marohnić"
      And I am logged in as "mislav"
     When I go to the account settings page

  Scenario: Mislav updates his profile
     When I follow "Profile Information"
     Then I should see "Your Profile Settings" within "h2"
     When I fill in the following:
         | First name        | Mis                      |
         | Last name         | Mar                      |
         | Biography         | Ruby Rockstar Programmer |
      And I press "Update account"
     Then I should see "User profile updated!" within ".flash_success div"
     When I follow "mislav"
     Then I should see "Mis Mar" within ".banner h2"
      And I should see "Ruby Rockstar Programmer" within ".biography"

  Scenario: Mislav updates his profile picture
     When I follow "Profile Picture"
     Then I should see "Your Profile Picture" within "h2"
     When I attach the file at "features/support/sample_files/dragon.jpg" to "user_avatar"
      And I press "Update account"
     Then I should not see missing avatar image within ".column"

  Scenario: Mislav fails to update his profile picture with blank
  Scenario: Mislav fails to update his profile picture because its too big

  Scenario: Mislav updates his notifications
   When I follow "Notifications"
   Then I should see "Your Notifications"
   When I check "Notify me when I'm mentioned e.g. Howdy @mislav! You'll receive an email!"
    And I uncheck "Notify me when I'm watching a conversation"
    And I check "Notify me when I'm watching a task list"
    And I check "Notify me when I'm watching a task"
    And I check "Send me a daily email of my tasks"
    And I press "Update account"
   Then I should see "User profile updated!" within ".flash_success"
   When I follow "Notifications"
   Then I should see "Your Notifications"
    And the "Notify me when I'm mentioned e.g. Howdy @mislav! You'll receive an email!" checkbox should be checked
    And the "Notify me when I'm watching a conversation" checkbox should not be checked
    And the "Notify me when I'm watching a task list" checkbox should be checked
    And the "Notify me when I'm watching a task" checkbox should be checked
    And the "Send me a daily email of my tasks" checkbox should be checked

  Scenario: Mislav updates his username
      When I follow "Account Settings"
      Then I should see "Your Account Settings"
      When I fill in "Username" with "mislavrocks"
       And I press "Update account"
      Then I should see "User profile updated!" within ".flash_success"
       And I should see "mislavrocks"

  Scenario: Mislav fails to update his username because its already in use
  Scenario: Mislav fails to update his username with invalid format

  Scenario: Mislav updates his card profile information
  # Given I follow "Profile Information"
  #   And I should see "Your Profile Settings" within "h2"
  #  When I follow "+ Add Phone Number"
  #    And I fill in "user_card_attributes_phone_numbers_attributes_1260832025948_name" with "123456789"


  Scenario: Mislav fails to update his profile information