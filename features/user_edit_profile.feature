Feature: Update a profile

  Background: 
    Given a confirmed user exists with login: "mislav", first_name: "Mislav", last_name: "Marohnić"
    And I am logged in as @mislav
    When I go to the account settings page

  Scenario: Mislav updates his profile
    When I follow "Profile Information"
    Then I should see "Your Profile Settings" in the title
    When I fill in the following:
      | First name | Mis                      |
      | Last name  | Mar                      |
      | Biography  | Ruby Rockstar Programmer |
    And I press "Update account"
    Then I should see "User profile updated!"
    When I follow "mislav"
    Then I should see "Mis Mar"
    And I should see "Ruby Rockstar Programmer"

  Scenario: Mislav updates his profile picture
    When I follow "Profile Picture"
    Then I should see "Your Profile Picture"
    When I attach the file "features/support/sample_files/dragon.jpg" to "user_avatar"
    And I press "Update account"
    Then I should not see missing avatar image within ".column"

  Scenario: Mislav fails to update his profile picture with blank

  Scenario: Mislav fails to update his profile picture because its too big

  Scenario: Mislav updates his notifications
    When I follow "Notifications"
    Then I should see "Your Notifications"
    And I uncheck "Notify me of updates to conversations I'm watching"
    And I check "Notify me of updates to tasks I'm watching"
    And I check "Send me a daily reminder of tasks assigned to me that are due soon"
    And I press "Update account"
    Then I should see "User profile updated!"
    When I follow "Notifications"
    Then I should see "Your Notifications"
    And the "Notify me of updates to conversations I'm watching" checkbox should not be checked
    And the "Notify me of updates to tasks I'm watching" checkbox should be checked
    And the "Send me a daily reminder of tasks assigned to me that are due soon" checkbox should be checked

  Scenario: Mislav updates his username
    When I follow "Account Settings"
    Then I should see "Your Account Settings"
    When I fill in "Username" with "mislavrocks"
    And I press "Update account"
    Then I should see "User profile updated!"
    And I should see "mislavrocks"

  Scenario: Mislav fails to update his username because its already in use

  Scenario: Mislav fails to update his username with invalid format

  Scenario: Mislav updates his card profile information

  # Given I follow "Profile Information"
  #   And I should see "Your Profile Settings" within "h2"
  #  When I follow "+ Add Phone Number"
  #    And I fill in "user_card_attributes_phone_numbers_attributes_1260832025948_name" with "123456789"
  Scenario: Mislav fails to update his profile information

