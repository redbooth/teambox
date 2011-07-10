require 'spec_helper'

describe Folder do

  it { should belong_to(:user) }
  it { should belong_to(:project) }

  pending "model validations" do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name, :within => Folder::NAME_LENGTH) }
    it { should validate_uniqueness_of(:name) }
  end

  describe "a new root folder" do
    before do
      @project = Factory(:project)
      @user = Factory(:user)
      @project.add_user(@user)
      @folder = Factory(:folder, :project => @project, :user => @user)
    end

    it "should have no parent" do
      @folder.has_parent?.should be_false
    end

    it "should show correct child folders count" do
      5.times do
        Factory(:folder, :project => @project, :user => @user, :parent_folder_id => @folder.id)
      end
      @folder.folders_count.should eql(5)
      @folder.has_children?.should be_true
    end

    it "should have correct uploads count" do
      2.times do
        Factory(:upload, :parent_folder_id => @folder.id)
      end
      @folder.uploads_count.should eql(2)
    end

  end

end