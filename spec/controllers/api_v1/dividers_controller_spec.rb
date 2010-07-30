require 'spec_helper'

describe ApiV1::DividersController do
  before do
    make_a_typical_project
    
    @page = @project.new_page(@owner, {:name => 'Divisions'})
    @page.save!
    
    @divider = @page.build_divider({:name => 'Drawing a line here'}).tap do |n|
      n.updated_by = @owner
      @page.new_slot(0, true, n) if n.save
    end
  end
  
  describe "#index" do
    it "shows dividers in a page" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :page_id => @page.id
      response.should be_success
      
      JSON.parse(response.body).length.should == 1
    end
  end
  
  describe "#show" do
    it "shows a divider" do
      login_as @user
      
      get :show, :project_id => @project.permalink, :page_id => @page.id, :id => @divider.id
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @divider.id
    end
  end
  
  describe "#create" do
    it "should allow participants to create dividers" do
      login_as @user
      
      post :create, :project_id => @project.permalink, :page_id => @page.id, :divider => {:name => 'Divisions'}
      response.should be_success
      
      @page.dividers(true).length.should == 2
      @page.dividers.last.name.should == 'Divisions'
    end
    
    it "should not allow observers to create dividers" do
      login_as @observer
      
      post :create, :project_id => @project.permalink, :page_id => @page.id, :divider => {:name => 'Divisions'}
      response.status.should == '401 Unauthorized'
      
      @page.dividers(true).length.should == 1
    end
  end
  
  describe "#update" do
    it "should allow participants to modify a divider" do
      login_as @user
      
      put :update, :project_id => @project.permalink, :page_id => @page.id, :id => @divider.id, :divider => {:name => 'Modified'}
      response.should be_success
      
      @divider.reload.name.should == 'Modified'
    end
    
    it "should not allow observers to modify a divider" do
      login_as @observer
      
      put :update, :project_id => @project.permalink, :page_id => @page.id, :id => @divider.id, :divider => {:name => 'Modified'}
      response.status.should == '401 Unauthorized'
      
      @divider.reload.name.should_not == 'Modified'
    end
  end
  
  describe "#destroy" do
    it "should allow participants to destroy a divider" do
      login_as @user
      
      put :destroy, :project_id => @project.permalink, :page_id => @page.id, :id => @divider.id
      response.should be_success
      
      @page.dividers(true).length.should == 0
    end
    
    it "should not allow observers to destroy a divider" do
      login_as @observer
      
      put :destroy, :project_id => @project.permalink, :page_id => @page.id, :id => @divider.id
      response.status.should == '401 Unauthorized'
      
      @page.dividers(true).length.should == 1
    end
  end
end