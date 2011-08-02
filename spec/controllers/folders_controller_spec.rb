require 'spec_helper'

describe FoldersController do
  render_views

  before do
    make_a_typical_project
  end

  describe "#create" do
    it "should allow participants to create folders" do
      login_as @user

      post :create,
           :project_id => @project.id,
           :folder => {:name => "The X-files", :user_id => @user.id}

      @project.folders(true).length.should == 1
    end

    it "should not allow observers to create folders" do
      login_as @observer

      post :create,
           :project_id => @project.id,
           :folder => {:name => "The Y-files", :user_id => @user.id}

      @project.folders(true).length.should == 0
    end

  end

  describe "#destroy" do

    before do 
      @folder = Factory(:folder, :project_id => @project.id, :user_id => @user.id)
    end

    it "should allow participants to delete folders" do
      login_as @user
      
      delete :destroy, :project_id => @project.permalink, :id => @folder.id
      @project.folders(true).length.should == 0
    end

    it "should not allow observers to delete folders" do
      login_as @observer

      delete :destroy, :project_id => @project.permalink, :id => @folder.id
      @project.folders(true).length.should == 1
    end

  end

  describe "#rename" do

    before do
      @folder = Factory(:folder, :project_id => @project.id, :user_id => @user.id, :name => 'Keep this name')
    end

    it "should allow participants to rename folders" do
      login_as @user

      put :rename, :project_id => @project.permalink, :id => @folder.id,
           :folder => {:name => "Changed"}

      @folder.reload
      @folder.name.should eql 'Changed'
    end

    it "should not allow observers to create folders" do
      login_as @observer

      put :rename, :project_id => @project.permalink, :id => @folder.id,
           :folder => {:name => "Wanna change"}

      @folder.reload
      @folder.name.should eql 'Keep this name'
    end

  end

end