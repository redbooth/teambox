require 'spec_helper'

describe Folder do

  before do
    @project = Factory(:project)
    @user = Factory(:user)
    @project.add_user(@user)
    @folder = Factory(:folder, :project => @project, :user => @user)
  end

  describe 'validate' do
    it { should belong_to(:user) }
    it { should belong_to(:project) }
    it { should validate_length_of(:name, :within => Folder::NAME_LENGTH) }
  end

  describe "a new root folder" do
    
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

  describe "any folder" do
    before do
      @name = @folder.name
    end
    
    it "should not allow create a neighbour folder with the same name" do
      @neighbour_folder = Folder.create(:name => @name, :project => @project, :user => @user)
      @neighbour_folder.should_not be_valid
    end

    it "should allow create a folder with the same name but in different path" do
      @child_folder = Factory(:folder, :project => @project, :user => @user, :parent_folder_id => @folder.id)
      @same_name_folder = Factory(:folder, :name => @name, :project => @project, :user => @user, :parent_folder_id => @child_folder.id)
      @same_name_folder.should be_valid
    end
  end

end