require 'spec_helper'

describe EmailValidator do
  
  it "should pass valid email addresses" do
    ["billg@microsoft.com",
     "user+email@gmail.com",
     "firstname.lastname@gmail.com",
     "user@localhost.com"].each do |address|
      EmailValidator.check_address(address).should_not == false
    end
  end
  
  it "should fail on invalid email addresses" do
    ["@foo@gmail.com",
      "foo@",
      "@gmail.com",
      "user@localhost"].each do |address|
      EmailValidator.check_address(address).should == false
    end
  end

end
