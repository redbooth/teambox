require File.dirname(__FILE__) + '/../spec_helper'

describe UploadsController do
  before do
    make_a_typical_project
    
    @upload = @project.uploads.new({:asset => mock_uploader('semicolons.js', 'application/javascript', "alert('what?!')")})
    @upload.user = @user
    @upload.save!
    
    @page_upload = mock_file(@user, Factory.create(:page, :project_id => @project.id))
    @page = @page_upload.page
    @page.reload
  end
  
  route_matches("/downloads/22/original/test", 
    :get, 
    :controller => "uploads", 
    :action => "download", 
    :filename =>"test", :id => "22", :style => "original")
  route_matches("/downloads/22/original/test......", 
    :get, 
    :controller => "uploads", 
    :action => "download", 
    :filename =>"test......", :id => "22", :style => "original")
  route_matches("/downloads/22/original/test.test",          
    :get, 
    :controller => "uploads", 
    :action => "download", 
    :filename =>"test.test", :id => "22", :style => "original")
  route_matches("/downloads/22/original/test.jpg",           
    :get, 
    :controller => "uploads", 
    :action => "download", 
    :filename =>"test.jpg", :id => "22", :style => "original")
  route_matches("/downloads/22/original/test.test.jpg",      
    :get, 
    :controller => "uploads", 
    :action => "download", 
    :filename =>"test.test.jpg", :id => "22", :style => "original")
  route_matches("/downloads/22/original/test.test.test.jpg", 
    :get, 
    :controller => "uploads", 
    :action => "download", 
    :filename =>"test.test.test.jpg", :id => "22", :style => "original")

  describe "#create" do
    it "should allow participants to create uploads" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :upload => {:asset => mock_uploader('lawsuit.txt', 'text/plain', "1 million dollars please")}
      
      @project.uploads(true).length.should == 3
      @project.uploads.last.asset.original_filename.should == 'lawsuit.txt'
    end
    
    it "should insert uploads at the top of a page" do
      login_as @user
      old_id = @page.slots.first.rel_object.id
      
      post :create,
           :project_id => @project.permalink,
           :upload => mock_file_params.merge(:page_id => @page.id),
           :position => {:slot => 0, :before => true}
      response.should redirect_to(project_page_path(@project,@page))
      
      @page.slots(true).first.rel_object.id.should_not == old_id
    end
    
    it "should insert uploads at the footer of a page" do
      login_as @user
      old_id = @page.slots.first.rel_object.id
      
      post :create,
           :project_id => @project.permalink,
           :upload => mock_file_params.merge(:page_id => @page.id),
           :position => {:slot => -1}
      response.should redirect_to(project_page_path(@project,@page))
      
      @page.slots(true).last.rel_object.id.should_not == old_id
    end
    
    it "should insert uploads before an existing widget" do
      login_as @user
      slot_ids = @page.slot_ids
      
      post :create,
           :project_id => @project.permalink,
           :upload => mock_file_params.merge(:page_id => @page.id),
           :position => {:slot => @page_upload.page_slot.id, :before => 1}
      response.should redirect_to(project_page_path(@project,@page))
      
      new_slot_id = (@page.slot_ids(true) - slot_ids)[0]
      @page.slots.find_by_id(new_slot_id).position.should == @page_upload.page_slot.reload.position-1
    end
    
    it "should insert uploads after an existing widget" do
      login_as @user
      slot_ids = @page.slot_ids
      
      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :upload => mock_file_params.merge(:page_id => @page.id),
           :position => {:slot => @page_upload.page_slot.id, :before => 0}
      response.should redirect_to(project_page_path(@project,@page))
      
      new_slot_id = (@page.slot_ids(true) - slot_ids)[0]
      @page.slots.find_by_id(new_slot_id).position.should == @page_upload.page_slot.reload.position+1
    end
    
    it "should not allow observers to create uploads" do
      login_as @observer
      
      post :create, :project_id => @project.permalink, :id => @upload.id, 
           :upload =>  {:asset => mock_uploader('lawsuit.txt', 'text/plain', "1 million dollars please")}
      
      @project.uploads(true).length.should == 2
    end
  end
  describe "#destroy" do
    it "should allow participants to destroy uploads" do
      login_as @user

      delete :destroy, :project_id => @project.permalink, :id => @upload.id

      @project.uploads.length.should == 1
    end
    it  "should destroy the activty when the upload is destroyed" do
      login_as @user

      post :create,
           :project_id => @project.permalink,
           :upload => {:asset => mock_uploader('lawsuit.txt', 'text/plain', "1 million dollars please")}

      @upload = Upload.find(:first, :order => 'created_at desc')
      Activity.count(:conditions => {:target_type => @upload.class.name, :target_id => @upload.id}).should == 1
      lambda { delete :destroy, :project_id => @project.permalink, :id => @upload.id }.should change(Activity, :count)
    end
  end
end
