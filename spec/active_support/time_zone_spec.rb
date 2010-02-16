require File.dirname(__FILE__) + '/../spec_helper'

describe ActiveSupport::TimeZone do
  describe "zones with time diff. to UTC" do
    it "should include 'Amsterdam' when called with +1" do
      time_zones = ActiveSupport::TimeZone.zones_with_time_diff_to_utc(1)
      time_zones.map(&:name).should include('Amsterdam')
    end
    
    it "should include 'Amsterdam' when called with 3600" do
      time_zones = ActiveSupport::TimeZone.zones_with_time_diff_to_utc(3600)
      time_zones.map(&:name).should include('Amsterdam')
    end
    
    it "should include 'Eastern Time' when called with -5" do
      time_zones = ActiveSupport::TimeZone.zones_with_time_diff_to_utc(-5)
      time_zones.map(&:name).should include("Eastern Time (US & Canada)")
    end
    
    it "should include 'Eastern Time' when called with -18_000" do
      time_zones = ActiveSupport::TimeZone.zones_with_time_diff_to_utc(-18_000)
      time_zones.map(&:name).should include("Eastern Time (US & Canada)")
    end
  end
end