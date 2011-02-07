require 'spec_helper'

describe Card do

  it "should destroy dependent phone numbers when destroyed" do
    card = Card.new
    card.phone_numbers_attributes = {"0" => { :name => "93 123 45 67", :account_type => 0 }}

    lambda {
      card.save.should be_true
    }.should change(described_class, :count)

    card.phone_numbers.should_not be_empty

    phone_number = card.phone_numbers.first
    card.destroy
    card.should be_frozen
    lambda {
      phone_number.reload
    }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it "should destroy dependent email addresses when destroyed" do
    card = Card.new
    card.email_addresses_attributes = {"0" => { :name => "jordi@teamboc.com", :account_type => 0 }}

    lambda {
      card.save.should be_true
    }.should change(described_class, :count)

    card.email_addresses.should_not be_empty

    email_address = card.email_addresses.first
    card.destroy
    card.should be_frozen
    lambda {
      email_address.reload
    }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it "should destroy dependent addresses when destroyed" do
    card = Card.new
    card.addresses_attributes = {"0" => { :street => "Gran via", :city => "Barcelona", :zip => '08082', :state => 'Barcelona', :country => 'Spain' }}

    lambda {
      card.save.should be_true
    }.should change(described_class, :count)

    card.addresses.should_not be_empty

    address = card.addresses.first
    card.destroy
    card.should be_frozen
    lambda {
      address.reload
    }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it "should destroy dependent websites when destroyed" do
    card = Card.new
    card.websites_attributes = {"0" => { :name => "teamboc.com", :account_type => 0 }}

    lambda {
      card.save.should be_true
    }.should change(described_class, :count)

    card.websites.should_not be_empty

    website = card.websites.first
    card.destroy
    card.should be_frozen
    lambda {
      website.reload
    }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it "should destroy dependent im's when destroyed" do
    card = Card.new
    card.ims_attributes = {"0" => { :name => "jordiromero", :account_type => 0, :account_im_type => 0 }}

    lambda {
      card.save.should be_true
    }.should change(described_class, :count)

    card.ims.should_not be_empty

    im = card.ims.first
    card.destroy
    card.should be_frozen
    lambda {
      im.reload
    }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it "should destroy dependent social networks when destroyed" do
    card = Card.new
    card.social_networks_attributes = {"0" => { :name => "jordiromero", :account_type => 0, :account_network_type => 0 }}

    lambda {
      card.save.should be_true
    }.should change(described_class, :count)

    card.social_networks.should_not be_empty

    social_network = card.social_networks.first
    card.destroy
    card.should be_frozen
    lambda {
      social_network.reload
    }.should raise_error(ActiveRecord::RecordNotFound)
  end
end

