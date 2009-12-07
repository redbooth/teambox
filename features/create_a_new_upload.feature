Feature Uploading a file
  Background:
    Given I am logged in as mislav
      And I am currently in the project ruby_rockstars

  Scenario: Mislav uploads a valid file with success
    Given I am on the uploads page
     When I attach the file at "features/support/sample_files/dragon.jpg" to "upload_asset"
      And I press "Upload file"
     Then I should see "dragon.jpg" within ".upload"
      

  Scenario: Mislav tries to upload a file with no asset and fails
    Given I am on the uploads page
      And I press "Upload file"
     Then I should see "You can't upload a blank file" within ".form_error"
     
   Scenario: Mislav tries to upload a file thats too big (that's what she said)
     Given I am on the uploads page
      When I attach the file at "features/support/sample_files/dragon.jpg" to "upload_asset"
       And I press "Upload file"
      Then I should see "File size can't exceed 1 bytes" within ".form_error"  