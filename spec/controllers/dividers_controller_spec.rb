require 'spec_helper'

describe DividersController do
  before do
    make_a_typical_project
    
    @page = @project.new_page(@owner, {:name => 'Divisions'})
    @page.save!
    
    @divider = @page.build_divider({:name => 'Drawing a line here'}).tap do |n|
      n.updated_by = @owner
      n.save
    end
  end
  
  describe "#create" do
    it "should allow participants to create dividers" do
      login_as @user
      
      post :create, :project_id => @project.permalink, :page_id => @page.id, :divider => {:name => 'Divisions'}
      response.should redirect_to(project_page_path(@project,@page))
      
      @page.dividers(true).length.should == 2
      @page.dividers.last.name.should == 'Divisions'
    end
    
    it "should insert dividers at the top of a page" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :divider => {:name => 'AT_TOP'},
           :position => {:slot => 0, :before => true}
      
      @page.slots(true).first.rel_object.name.should == 'AT_TOP'
    end
    
    it "should insert dividers at the footer of a page" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :divider => {:name => 'AT_BOTTOM'},
           :position => {:slot => -1}
      response.should redirect_to(project_page_path(@project,@page))
      
      @page.slots(true).last.rel_object.name.should == 'AT_BOTTOM'
    end
    
    it "should insert dividers before an existing widget" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :divider => {:name => 'BEFORE'},
           :position => {:slot => @divider.page_slot.id, :before => 1}
      response.should redirect_to(project_page_path(@project,@page))
      
      @page.slots(true)[0].rel_object.name.should == 'BEFORE'
    end
    
    it "should insert dividers after an existing widget" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :divider => {:name => 'AFTER'},
           :position => {:slot => @divider.page_slot.id, :before => 0}
      response.should redirect_to(project_page_path(@project,@page))
      
      @page.slots(true)[1].rel_object.name.should == 'AFTER'
    end
    
    it "should not allow observers to create dividers" do
      login_as @observer
      
      post :create, :project_id => @project.permalink, :page_id => @page.id, :divider => {:name => 'Divisions'}
      
      @page.dividers(true).length.should == 1
    end
  end
  
  describe "#edit" do
    it "should redirect for html" do
      login_as @owner
      get :edit, :project_id => @project.permalink, :page_id => @page.id, :id => @divider.id
      response.should be_redirect
    end
    
    it "should render for m" do
      login_as @owner
      get :edit, :project_id => @project.permalink, :page_id => @page.id, :id => @divider.id, :format => 'm'
      response.should render_template('dividers/edit')
    end
  end
end