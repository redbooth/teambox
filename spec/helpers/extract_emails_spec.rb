require 'spec_helper'

describe 'String#extract_emails' do

  context "valid" do
    it "extracts single email from: pablo@teambox.com" do
      should == %w[ pablo@teambox.com ]
    end

    it "extracts multiple emails from: c@c.com word d@d.com\ne@f.com" do
      should == %w[ c@c.com d@d.com e@f.com ]
    end

    it "extracts header-style emails from: 'Pablo' <pablo2@teambox.com>, 'Juan Jaramillo'" do
      should == %w[ pablo2@teambox.com ]
    end

    it "handles two-part TLD from: james@cuppadev.co.uk" do
      should == %w[ james@cuppadev.co.uk ]
    end

    it "doesn't munge the username part from: a.fish@example.co.uk" do
      should == %w[ a.fish@example.co.uk ]
    end

    it "handles plus-addressing from: ohyeah+teambox@gmail.com" do
      should == %w[ ohyeah+teambox@gmail.com ]
    end

    it "extracts email with numbers from: l3tt3rsAndNumb3rs@domain.com" do
      should == %w[ l3tt3rsAndNumb3rs@domain.com ]
    end

    it "extracts email with dash from: has-dash@domain.com" do
      should == %w[ has-dash@domain.com ]
    end

    it "doesn't trip on an apostrophe from: hasApostrophe.o'leary@domain.org" do
      should == %w[ hasApostrophe.o'leary@domain.org ]
    end

    it "doesn't extract leading apostrophe from: 'hello@domain.org'" do
      should == %w[ hello@domain.org ]
    end

    it "extracts the email with a 'travel' TLD from: uncommon@domain.travel" do
      should == %w[ uncommon@domain.travel ]
    end

    it "extracts the email with numbers in domain from: numbers@911.com" do
      should == %w[ numbers@911.com ]
    end

    it "extracts the email with uppercase domain from: hello@gMAIL.COM" do
      should == %w[ hello@gMAIL.COM ]
    end

    it "handles domain specified with an IP & port from: IPAndPort@127.0.0.1:25" do
      should == %w[ IPAndPort@127.0.0.1:25 ]
    end

    it "extracts email with subdomains from: subdomain@sub.domain.com" do
      should == %w[ subdomain@sub.domain.com ]
    end

    it "doesn't trip on whacky characters from: ~&*=?^+{}'@validCharsInLocal.net" do
      should == %w[ ~&*=?^+{}'@validCharsInLocal.net ]
    end
  end

  context "invalid" do
    it "doesn't extract invalid email from: inv@lid brr" do
      should be_empty
    end

    it "detects missing domain from: missingDomain@.com" do
      should be_empty
    end

    it "trips on missing dot from: missingDot@com" do
      should be_empty
    end

    it "dislikes two @ signs from: two@@signs.com" do
      should be_empty
    end

    it "can't handle missing TLD from: missingTLD@domain." do
      should be_empty
    end
  end

  context "destructive" do
    it "should remove the emails from the original string" do
      string = "Some string with an email@address.com"
      emails = string.extract_emails!
      emails.should == ['email@address.com']
      string.should == "Some string with an "
    end
  end

  protected

  def subject
    data = description.match(/from: (.+)$/m)[1]
    data.extract_emails
  end

end

