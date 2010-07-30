require 'spec_helper'

describe ApiV1::UploadsController do
  before do
    make_a_typical_project
    
    @upload = @project.uploads.new({:asset => mock_uploader('semicolons.js', 'application/javascript', "alert('what?!')")})
    @upload.user = @user
    @upload.save!
  end
  
  describe "#index" do
    it "shows uploads in the project" do
      login_as @user
      
      get :index, :project_id => @project.permalink
      response.should be_success
      
      JSON.parse(response.body).length.should == 1
    end
    
    it "limits and offsets uploads" do
      login_as @user
      
      other_upload = @project.uploads.new({:asset => mock_uploader('semicolons.js', 'application/javascript', "alert('no way!!')")})
      other_upload.user = @user
      other_upload.save!
      
      get :index, :project_id => @project.permalink, :since_id => @project.reload.upload_ids[0], :count => 1
      response.should be_success
      
      JSON.parse(response.body).map{|a| a['id'].to_i}.should == [@project.reload.upload_ids[1]]
    end
  end
  
  describe "#show" do
    it "shows an upload" do
      login_as @user
      
      get :show, :project_id => @project.permalink, :id => @upload.id
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @upload.id
    end
  end
  
  describe "#create" do
    it "should allow participants to create uploads" do
      login_as @user
      
      post :create, :project_id => @project.permalink, :id => @upload.id, 
           :upload =>  {:asset => mock_uploader('lawsuit.txt', 'text/plain', "1 million dollars please")}
      response.should be_success
      
      @project.uploads(true).length.should == 2
      @project.uploads.last.asset.original_filename.should == 'lawsuit.txt'
    end
    
    it "should not allow observers to create uploads" do
      login_as @observer
      
      post :create, :project_id => @project.permalink, :id => @upload.id, 
           :upload =>  {:asset => mock_uploader('lawsuit.txt', 'text/plain', "1 million dollars please")}
      response.status.should == '401 Unauthorized'
      
      @project.uploads(true).length.should == 1
    end
  end
  
  describe "#destroy" do
    it "should allow participants to destroy an upload" do
      login_as @user
      
      put :destroy, :project_id => @project.permalink, :id => @upload.id
      response.should be_success
      
      @project.uploads(true).length.should == 0
    end
    
    it "should not allow observers to destroy an upload" do
      login_as @observer
      
      put :destroy, :project_id => @project.permalink, :id => @upload.id
      response.status.should == '401 Unauthorized'
      
      @project.uploads(true).length.should == 1
    end
  end
end