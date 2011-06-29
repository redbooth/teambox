require 'spec_helper'

describe GoogleCalendar do
  context "creating urls" do
    it "should generate a valid url when sent #create_url for list with no options" do
      calendar = GoogleCalendar.new('key', 'secret', nil)
      expected = "https://www.google.com/calendar/feeds/default/allcalendars/full?alt=jsonc"
      calendar.send(:create_url, GoogleCalendar::RESOURCES[:list_all]).should == expected
    end
  end
  
  context "A Calendar" do
    it "should correctly parse the json of a calendar" do
      calendar_json = '{"apiVersion":"1.0","data":{"kind":"calendar#calendar","id":"http://www.google.com/calendar/feeds/default/owncalendars/full/scsworld.co.uk_nnkr23qtc123gge26lihsmirjc%40group.calendar.google.com","created":"2011-05-18T13:45:05.411Z","updated":"2011-05-18T13:45:05.000Z","title":"Teambox","eventFeedLink":"https://www.google.com/calendar/feeds/scsworld.co.uk_nnkr23qtc123gge26lihsmirjc%40group.calendar.google.com/private/full","accessControlListLink":"https://www.google.com/calendar/feeds/scsworld.co.uk_nnkr23qtc123gge26lihsmirjc%40group.calendar.google.com/acl/full","selfLink":"https://www.google.com/calendar/feeds/default/owncalendars/full/scsworld.co.uk_nnkr23qtc123gge26lihsmirjc%40group.calendar.google.com","canEdit":true,"author":{"displayName":"Teambox"},"accessLevel":"root","color":"#2952A3","hidden":false,"selected":false,"timeZone":"UTC","timesCleaned":0}}'
      calendar = GoogleCalendar::Calendar.from_json_hash(MultiJson.decode(calendar_json)['data'])
      
      calendar.id.should == 'http://www.google.com/calendar/feeds/default/owncalendars/full/scsworld.co.uk_nnkr23qtc123gge26lihsmirjc%40group.calendar.google.com'
      calendar.url_token.should == 'scsworld.co.uk_nnkr23qtc123gge26lihsmirjc%40group.calendar.google.com'
      calendar.title.should == "Teambox"
      calendar.hidden.should == false
      calendar.color.should == "#2952A3"
      calendar.location.should == nil
      calendar.time_zone.should == "UTC"
    end
    
    it "should output the calendar in the correct format when created as a calendar" do
      calendar = GoogleCalendar::Calendar.new(
        :title => "Teambox",
        :hidden => 'false',
        :color => '#2952A3',
        :location => 'Location',
        :time_zone => 'UTC'
      )
      
      calendar.to_json be_equivelent_json_as '{"location":"Location","title":"Teambox","color":"#2952A3","timeZone":"UTC","hidden":"false"}'
    end
    
    it "should successfully treat time_zone as timeZone in the hash" do
      calendar = GoogleCalendar::Calendar.new
      calendar.time_zone = 'UTC'
      calendar.to_json.should be_equivelent_json_as '{"timeZone":"UTC"}'
    end
    
    it "should successfully round trip a calendar from and to json affecting additional parameters" do
      calendar_json = '{"apiVersion":"1.0","data":{"kind":"calendar#calendar","additional":"value","id":"http://www.google.com/calendar/feeds/default/owncalendars/full/scsworld.co.uk_nnkr23qtc123gge26lihsmirjc%40group.calendar.google.com","created":"2011-05-18T13:45:05.411Z","updated":"2011-05-18T13:45:05.000Z","title":"Teambox","eventFeedLink":"https://www.google.com/calendar/feeds/scsworld.co.uk_nnkr23qtc123gge26lihsmirjc%40group.calendar.google.com/private/full","accessControlListLink":"https://www.google.com/calendar/feeds/scsworld.co.uk_nnkr23qtc123gge26lihsmirjc%40group.calendar.google.com/acl/full","selfLink":"https://www.google.com/calendar/feeds/default/owncalendars/full/scsworld.co.uk_nnkr23qtc123gge26lihsmirjc%40group.calendar.google.com","canEdit":true,"author":{"displayName":"Teambox"},"accessLevel":"root","color":"#2952A3","hidden":false,"selected":false,"timeZone":"UTC","timesCleaned":0}}'
      calendar = GoogleCalendar::Calendar.from_json_hash(MultiJson.decode(calendar_json)['data'])
      calendar.title = 'Teambox2'
      calendar.to_json.should be_equivelent_json_as '{"kind":"calendar#calendar","timesCleaned":0,"accessLevel":"root","author":{"displayName":"Teambox"},"title":"Teambox2","canEdit":true,"timeZone":"UTC","selected":false,"color":"#2952A3","id":"http://www.google.com/calendar/feeds/default/owncalendars/full/scsworld.co.uk_nnkr23qtc123gge26lihsmirjc%40group.calendar.google.com","additional":"value","selfLink":"https://www.google.com/calendar/feeds/default/owncalendars/full/scsworld.co.uk_nnkr23qtc123gge26lihsmirjc%40group.calendar.google.com","accessControlListLink":"https://www.google.com/calendar/feeds/scsworld.co.uk_nnkr23qtc123gge26lihsmirjc%40group.calendar.google.com/acl/full","eventFeedLink":"https://www.google.com/calendar/feeds/scsworld.co.uk_nnkr23qtc123gge26lihsmirjc%40group.calendar.google.com/private/full","updated":"2011-05-18T13:45:05.000Z","hidden":false,"created":"2011-05-18T13:45:05.411Z"}'
    end
  end
  
  context "An Event" do
    it "should correctly parse the json of an event" do
      event_json = '{"apiVersion":1.0, "data":{"title": "Tennis with Beth","details":"Meet for a quick lesson.","transparency":"opaque","status":"confirmed","location":"Rolling Lawn Courts","when":[{"start":"2010-04-17T15:00:00+00:00","end":"2010-04-17T17:00:00+00:00"}]}}'
      event = GoogleCalendar::Event.from_json_hash(MultiJson.decode(event_json)['data'])
      
      event.title.should == "Tennis with Beth"
      event.details.should == "Meet for a quick lesson."
      event.transparency.should == "opaque"
      event.status.should == "confirmed"
      event.location.should == "Rolling Lawn Courts"
      event.start.should == DateTime.new(2010, 04, 17, 15, 00, 00)
      event.end.should == DateTime.new(2010, 04, 17, 17, 00, 00)
    end
    
    it "should output the event details in the correct json when created as an event" do
      event = GoogleCalendar::Event.new(
        :title => 'title',
        :details => 'details',
        :transparency => 'opaque',
        :status => 'confirmed',
        :location => 'location',
        :start => DateTime.new(2010, 04, 17, 15, 00, 00), # these convenience methods should be placed into the when field
        :end => DateTime.new(2010, 04, 17, 17, 00, 00)
      )
      
      event.to_json.should be_equivelent_json_as '{"location":"location","title":"title","details":"details","transparency":"opaque","when":[{"end":"2010-04-17T17:00:00+00:00","start":"2010-04-17T15:00:00+00:00"}],"status":"confirmed"}'
    end
    
    it "should successfully allow editing of the start and end date" do
      event_json = '{"apiVersion":1.0, "data":{"title": "Tennis with Beth","details":"Meet for a quick lesson.","transparency":"opaque","status":"confirmed","location":"Rolling Lawn Courts","when":[{"start":"2010-04-17T15:00:00+00:00","end":"2010-04-17T17:00:00+00:00"}]}}'
      event = GoogleCalendar::Event.from_json_hash(MultiJson.decode(event_json)['data'])
      event.start = DateTime.new(2010, 8, 25, 12, 00, 00)
      
      event.start.should == DateTime.new(2010, 8, 25, 12, 00, 00)
      event.end.should == DateTime.new(2010, 04, 17, 17, 00, 00)
      
      event.end = DateTime.new(2010, 8, 25, 14, 00, 00)
      
      event.start.should == DateTime.new(2010, 8, 25, 12, 00, 00)
      event.end.should == DateTime.new(2010, 8, 25, 14, 00, 00)
      event.to_json.should be_equivelent_json_as '{"location":"Rolling Lawn Courts","details":"Meet for a quick lesson.","title":"Tennis with Beth","transparency":"opaque","when":[{"end":"2010-08-25T14:00:00+00:00","start":"2010-08-25T12:00:00+00:00"}],"status":"confirmed"}'
    end
    
    it "should successfully pass only dates and no times if we create an all day event" do
      calendar = GoogleCalendar::Event.new(
        :title => 'title',
        :start => Date.new(2011, 8, 25),
        :end => Date.new(2011, 8, 25)
      )
      
      calendar.to_json.should be_equivelent_json_as '{"title":"title","when":[{"end":"2011-08-25","start":"2011-08-25"}]}'
    end
    
    it "should create a DateTime when passed a start or end date date with a time" do
      event_json = '{"title":"title","when":[{"end":"2010-08-25T14:00:00+00:00","start":"2010-08-25T12:00:00+00:00"}]}'
      event = GoogleCalendar::Event.from_json_hash(MultiJson.decode(event_json))
      
      event.start.should be_instance_of(DateTime)
      event.end.should be_instance_of(DateTime)
      
      event.start.should_not be_instance_of(Date)
      event.end.should_not be_instance_of(Date)
    end
    
    it "should create a Date when passed a start or end date date WITHOUT a time " do
      event_json = '{"title":"title","when":[{"end":"2011-08-25","start":"2011-08-25"}]}'
      event = GoogleCalendar::Event.from_json_hash(MultiJson.decode(event_json))
      
      event.start.should be_instance_of(Date)
      event.end.should be_instance_of(Date)
      
      event.start.should_not be_instance_of(DateTime)
      event.end.should_not be_instance_of(DateTime)
    end
    
    it "should successfully allow a roundtrip without affecting additional parameters" do
      event_json = '{"apiVersion":1.0, "data":{"additional":"value","title": "Tennis with Beth","details":"Meet for a quick lesson.","transparency":"opaque","status":"confirmed","location":"Rolling Lawn Courts","when":[{"start":"2010-04-17T15:00:00+00:00","end":"2010-04-17T17:00:00+00:00"}]}}'
      event = GoogleCalendar::Event.from_json_hash(MultiJson.decode(event_json)['data'])
      event.location = "new location"
      output_json = event.to_json
      
      output_json.should be_equivelent_json_as '{"location":"new location","details":"Meet for a quick lesson.","title":"Tennis with Beth","transparency":"opaque","additional":"value","when":[{"end":"2010-04-17T17:00:00+00:00","start":"2010-04-17T15:00:00+00:00"}],"status":"confirmed"}'
    end
  end
  
  context "Posting Data" do
    it "should correctly format json post data from hashes" do
      event = GoogleCalendar::Event.new(:title => 'title_value', :details => 'details_value')
      post_body = GoogleCalendar.send(:create_post_data, event)
      
      post_body.should be_equivelent_json_as '{"apiVersion":"2.6","data":{"details":"details_value","title":"title_value"}}'
    end
  end
end