require File.dirname(__FILE__) + '/../spec_helper'

describe String do

  it "should extract valid emails" do
    "pablo@teambox.com".extract_emails.should == ["pablo@teambox.com"]
    "a@a.com b@b.com".extract_emails.should == %w(a@a.com b@b.com)
    "  c@c.com word d@d.com\ne@f.com".extract_emails.should == %w(c@c.com d@d.com e@f.com)
    "inv@lid brr".extract_emails.should == []
    "'Pablo' <pablo2@teambox.com>, 'Juan Jaramillo'".extract_emails.should == %w(pablo2@teambox.com)
    "james@cuppadev.co.uk".extract_emails.should == %w(james@cuppadev.co.uk)
  end
  
end