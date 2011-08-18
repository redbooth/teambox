require File.dirname(__FILE__) + '/../spec_helper'

describe UploadsController do
  render_views
  
  before do
    make_a_typical_project
    
    @upload = @project.uploads.new({:asset => mock_uploader('semicolons.js', 'application/javascript', "alert('what?!')")})
    @upload.user = @user
    @upload.save!
    
    @page_upload = mock_file(@user, Factory.create(:page, :project => @project))
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

  describe "#index" do
    before do
      @conversation = Factory.create(:conversation, :is_private => true, :user => @project.user, :project => @project)
      @upload.is_private = true
      @upload.comment = @conversation.comments.first
      @upload.save!
    end
    
    it "should not show private uploads belonging to targets we are not watching" do
      login_as @user
      get :index, :project_id => @project.permalink
      response.body.match(/semicolons\.js/).should == nil
    end
    
    it "shows private uploads belonging to objects we are a watcher of" do
      @conversation.add_watcher(@user)
      login_as @user
    
      get :index, :project_id => @project.permalink
      response.body.match(/semicolons\.js/).should_not == nil
    end
  end

  describe "#download of private uploads" do
    before do
      @conversation = Factory.create(:conversation, :is_private => true, :user => @project.user, :project => @project)
      @upload = @project.uploads.new({:asset => mock_uploader('lawsuit.txt', 'text/plain', "1 million dolalrs please")})

      @upload.user = @user
      @upload.is_private = true
      @upload.comment = @conversation.comments.first
      @upload.save!
    end
    
    it "should not allow downloading of private uploads belonging to targets we are not watching" do
      login_as @user
      get :download, :id => @upload.id, :filename => 'lawsuit.txt'
      response.body.match(/million/).should == nil
    end
    
    it "allows downloading of private uploads belonging to objects we are a watcher of" do
      @conversation.add_watcher(@user)
      login_as @user
    
      get :download, :id => @upload.id, :filename => 'lawsuit.txt'
      response.body.match(/million/).should_not == nil
    end
  end
  
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

  describe "#email_public" do
    it "should send email with download link" do
      login_as @user
      recepient = 'this.is@valid.ema.il'

      post :email_public, :project_id => @project.permalink, :id => @upload.id, :upload => {:invited_user_email => recepient}
      response.should redirect_to(project_uploads_path)

      last_email_sent.should deliver_to(recepient)

    end
  end

  describe "#edit" do
    it "should allow user to edit an upload" do
      login_as @user
      get :edit, :project_id => @project.permalink, :id => @upload.id, :format => :js
      assert_select_rjs :insert_html, :after, "upload_#{@upload.id}"
    end

    it "should not allow users with no rights to update uploads" do
      login_as Factory(:confirmed_user)
      get :edit, :project_id => @project.permalink, :id => @upload.id, :format => :js
      response.should_not be_success
    end
  end

  describe "#rename" do
    before do 
      login_as @user
      # until rspec gets any_instance
      @uploads = mock(Object)
      Project.stub!(:find_by_id_or_permalink).with(@project.id).and_return(@project)
      @project.stub!(:uploads).and_return(@uploads)
      @uploads.stub!(:find).and_return(@upload)
    end
    
    describe "JS request" do
      it "should allow user to rename an upload" do
        @upload.should_receive(:rename_asset).with("new_pic.png").and_return(true)
        put :rename, :project_id => @project.id, :id => @upload.id, :format => :js,
          :upload => {:asset_file_name => "new_pic.png"}
        assert_select_rjs :replace, "upload_#{@upload.id}"
      end

      it "should alert user on rename error" do
        @upload.should_receive(:rename_asset).with("new_pic.png").and_return(false)
        put :rename, :project_id => @project.id, :id => @upload.id, :format => :js,
          :upload => {:asset_file_name => "new_pic.png"}
        response.body.should match(/alert/)
      end
    end

    describe "HTML request" do
      it "should allow user to rename an upload" do
        @upload.should_receive(:rename_asset).with("new_pic.png").and_return(true)
        put :rename, :project_id => @project.id, :id => @upload.id,
          :upload => {:asset_file_name => "new_pic.png"}
        flash[:notice].should_not be_nil
        response.should redirect_to(project_uploads_path(@project))
      end

      it "should notify user on rename error" do
        @upload.should_receive(:rename_asset).with("new_pic.png").and_return(false)
        put :rename, :project_id => @project.id, :id => @upload.id,
          :upload => {:asset_file_name => "new_pic.png"}
        flash[:error].should_not be_nil
        response.should redirect_to(project_uploads_path(@project))
      end
    end
  end

end