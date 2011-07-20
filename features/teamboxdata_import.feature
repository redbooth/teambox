Feature: Importing data

Background: 
  Given a project exists with name: "Ruby Rockstars"
  And @mislav exists and is logged in
  And I am in the project called "Ruby Rockstars"
  And I am an administrator in the organization of the project called "Ruby Rockstars"
  And the organization of the project called "Ruby Rockstars" is called "Teambox Data"
  And deferred data processing is off

Scenario: Mislav imports an historic project
  When I go to the your data page
  And the following confirmed users exist
    | login  | email                    | first_name | last_name |
    | pablo  | pablo@teambox.com        | Pablo      | Villalba  |
    | frodo  | frodo@theshire.com       | Frodo      | Baggins   |
    | gandalf| gandalf@middleearth.com  | Gandalf    | Grey      |
  And I follow "Import"
  And I choose "Teambox"
  And I attach the file "spec/fixtures/teamboxdump.json" to "teambox_data_import_data"
  And I press "Import data"
  Then I should see "Andrew Wiggin (@gandhi_1)"
  And I should see "Andrew Wiggin (@gandhi_2)"
  And I should see "Andrew Wiggin (@gandhi_3)"
  And I should see "Andrew Wiggin (@gandhi_4)"
  When I select the following:
    | Andrew Wiggin (@gandhi_1)             |  Mislav Marohnić (@mislav) |
    | Andrew Wiggin (@gandhi_2)             |  Mislav Marohnić (@mislav) |
    | Andrew Wiggin (@gandhi_3)             |  Mislav Marohnić (@mislav) |
    | Andrew Wiggin (@gandhi_4)             |  Mislav Marohnić (@mislav) |
    | Put all projects in this organization | Teambox Data               |
  And I press "Import"
  Then I should see "Imported projects"
  And I should see "Teambox #1"
  And @mislav should receive 1 email
  And @pablo should receive no emails
  And @frodo should receive no emails
  And @gandalf should receive no emails
  And @mislav should receive 1 email with subject "Your data has been imported"

Scenario: Mislav imports another historic project
  When I go to the your data page
  And the following confirmed users exist
    | login  | email                    | first_name | last_name |
    | pablo  | pablo@teambox.com        | Pablo      | Villalba  |
    | frodo  | frodo@theshire.com       | Frodo      | Baggins   |
    | gandalf| gandalf@middleearth.com  | Gandalf    | Grey      |
  And "pablo" is an administrator in the organization of the project called "Ruby Rockstars"
  And "gandalf" is an administrator in the organization of the project called "Ruby Rockstars"
  And "frodo" is an administrator in the organization of the project called "Ruby Rockstars"
  And I follow "Import"
  And I choose "Teambox"
  And I attach the file "spec/fixtures/teamboxdump_problem.json" to "teambox_data_import_data"
  And I press "Import data"
  When I select the following:
    | Stevie Hobs (@steve_test2)            |  Mislav Marohnić (@mislav) |
    | Test Test (@steve_testing)            |  Pablo Villalba (@pablo)   |
    | Card Test (@stevecardtest)            |  Gandalf Grey (@gandalf)   |
    | Stevie Hobs (@steve)                  |  Frodo Baggins (@frodo)    |
    | Put all projects in this organization | Teambox Data               |
  And I press "Import"
  Then I should see "Imported projects"
  And I should see "Hobo Pro"
  And @mislav should receive 1 email
  And @pablo should receive no emails
  And @frodo should receive no emails
  And @gandalf should receive no emails

Scenario: Mislav gets fed up of Basecamp and moves to Teambox
  When I go to the your data page
  And I follow "Import"
  And I choose "Basecamp"
  And I attach the file "spec/fixtures/campdump.xml" to "teambox_data_import_data"
  And I press "Import data"
  Then I should see "Frodo Baggins (@FrodoBaggins)"
  When I select the following:
    | Frodo Baggins                         |  Mislav Marohnić (@mislav) |
    | Put all projects in this organization | Teambox Data               |
  And I press "Import"
  Then I should see "Imported projects"
  And I should see "Widgets"
  And @mislav should receive 1 email
  And @mislav should receive 1 email with subject "Your data has been imported"

Scenario: Mislav gets confused and uploads the wrong dump
  When I go to the your data page
  And I follow "Import"
  And I choose "Teambox"
  And I attach the file "spec/fixtures/campdump.xml" to "teambox_data_import_data"
  And I press "Import data"
  Then I should see "There was an error loading your import. Please try again."
  And @mislav should receive no emails

Scenario: Mislav forgets to map the data
  When I go to the your data page
  And I follow "Import"
  And I choose "Teambox"
  And I attach the file "spec/fixtures/teamboxdump.json" to "teambox_data_import_data"
  And I press "Import data"
  Then I should see "Andrew Wiggin (@gandhi_1)"
  And I should see "Andrew Wiggin (@gandhi_2)"
  And I should see "Andrew Wiggin (@gandhi_3)"
  And I should see "Andrew Wiggin (@gandhi_4)"
  And I press "Import"
  Then I should see "Should be an admin"
  And @mislav should receive no emails

Scenario: Mislav imports data with invalid records
  When I go to the your data page
  And I follow "Import"
  And I choose "Teambox"
  And I attach the file "spec/fixtures/teamboxdump_invalid.json" to "teambox_data_import_data"
  And I press "Import data"
  Then I should see "Andrew Wiggin (@gandhi_1)"
  And I should see "Andrew Wiggin (@gandhi_2)"
  And I should see "Andrew Wiggin (@gandhi_3)"
  And I should see "Andrew Wiggin (@gandhi_4)"
  When I select the following:
    | Andrew Wiggin (@gandhi_1)             |  Mislav Marohnić (@mislav) |
    | Andrew Wiggin (@gandhi_2)             |  Mislav Marohnić (@mislav) |
    | Andrew Wiggin (@gandhi_3)             |  Mislav Marohnić (@mislav) |
    | Andrew Wiggin (@gandhi_4)             |  Mislav Marohnić (@mislav) |
    | Put all projects in this organization | Teambox Data               |
  And I press "Import"
  Then I should see "There were errors with the information you supplied!"
  And @mislav should receive 1 email
  And @mislav should receive 1 email with subject "Your data could not be imported"
 
