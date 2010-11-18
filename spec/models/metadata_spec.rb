require File.dirname(__FILE__) + '/../spec_helper'

describe Metadata do

  describe "organization metadata" do
    before do
      Organization.default_settings = {'foo' => 'bar'}
      @organization = Factory(:organization)
    end

    it "should have class level defaults" do
      Organization.default_settings['foo'].should_not be_nil
    end

    it "should allow setting class level default metadata" do
      Organization.default_settings = {'foo' => 'baz'}
      Organization.default_settings['foo'].should == 'baz'
    end

    it "should default to class level defaults if unset" do
      @organization.settings.should == {'foo' => 'bar'}
    end

    it "should allow setting metadata on record instance" do
      @organization.settings = {'foo' => 'bang'}
      @organization.settings.should == {'foo' => 'bang'}
    end

    it "should deep merge new settings to existing settings" do
      @organization.settings = {'foo' => 'bang', 'baz' => 'biff'}
      @organization.settings.should == {'foo' => 'bang', 'baz' => 'biff'}
    end

    it "should not write to the database if not saved" do
      @organization.settings = {'foo' => 'bang', 'baz' => 'biff'}
      @organization.reload
      @organization.settings.should == {'foo' => 'bar'}
    end

    it "should encode data as json in the db" do
      @organization.settings = {'foo' => 'bang', 'baz' => 'biff'}
      ActiveSupport::JSON.decode(@organization.read_attribute('settings')).should == {'foo' => 'bang', 'baz' => 'biff'}
    end
  end
end
