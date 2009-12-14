Feature Uploading a file
  Background:
       Given I am logged in as mislav
         And I am currently in the project ruby_rockstars
         And I am on the uploads page
         And I follow "Upload a File"

   Scenario: Mislav uploads a valid file with success
       When I attach the file at "features/support/sample_files/dragon.jpg" to "upload_asset"
        And I press "Upload file"
        Then I should be on the uploads page
       Then I should see "dragon.jpg" within ".upload"

   Scenario: Mislav tries to upload a file with no asset and fails
       When I press "Upload file"
       Then I should be on the uploads page       
        And I should see "You can't upload a blank file" within ".form_error"
     
   Scenario: Mislav tries to upload a file thats too big (that's what she said)
       When I attach a "2" MB file called "rockets.jpg" to "upload_asset"
        And I press "Upload file"
       Then I should be on the uploads page        
        And I should see "File size can't exceed 1 MB" within ".form_error"
