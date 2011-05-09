require 'spec_helper'

describe GoogleDoc do
  it { should belong_to(:user) }
  it { should belong_to(:project) }
  it { should belong_to(:comment) }

  describe "factory" do
    it "should be valid" do
      google_doc = Factory.build(:google_doc)
      google_doc.should be_valid
    end
  end
end
