require File.dirname(__FILE__) + '/../spec_helper'

describe Page do

  it { should belong_to(:user) }
  it { should belong_to(:project) }
  it { should have_many(:notes) }
  it { should have_many(:dividers) }
  it { should have_many(:page_uploads) }

  describe "factories" do
    it "should generate a valid page" do
      page = Factory.create(:page)
      page.valid?.should be_true
    end
  end

end