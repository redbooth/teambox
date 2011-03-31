require 'spec_helper'

describe NotesController do
  before do
    make_a_typical_project
    
    @page = @project.new_page(@owner, {:name => 'New Employee Information'})
    @page.save!
    
    @note = @page.build_note({:name => 'Office Ettiquete'}).tap do |n|
      n.updated_by = @owner
      n.save
    end
  end
  
  describe "#create" do
    it "should allow participants to create notes" do
      login_as @user
      
      post :create, :project_id => @project.permalink, :page_id => @page.id, :note => {:name => 'Important!'}
      response.should redirect_to(project_page_path(@project,@page))
      
      @page.notes(true).length.should == 2
      @page.notes.last.name.should == 'Important!'
    end
    
    it "should insert notes at the top of a page" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :note => {:name => 'AT_TOP'},
           :position => {:slot => 0, :before => true}
      response.should redirect_to(project_page_path(@project,@page))
      
      @page.slots(true).first.rel_object.name.should == 'AT_TOP'
    end
    
    it "should insert notes at the footer of a page" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :note => {:name => 'AT_BOTTOM'},
           :position => {:slot => -1}
      response.should redirect_to(project_page_path(@project,@page))
      
      @page.slots(true).last.rel_object.name.should == 'AT_BOTTOM'
    end
    
    it "should insert notes before an existing widget" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :note => {:name => 'BEFORE'},
           :position => {:slot => @note.page_slot.id, :before => 1}
      response.should redirect_to(project_page_path(@project,@page))
      
      @page.slots(true)[0].rel_object.name.should == 'BEFORE'
    end
    
    it "should insert notes after an existing widget" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :note => {:name => 'AFTER'},
           :position => {:slot => @note.page_slot.id, :before => 0}
      response.should redirect_to(project_page_path(@project,@page))
      
      @page.slots(true)[1].rel_object.name.should == 'AFTER'
    end
    
    it "should not allow observers to create notes" do
      login_as @observer
      
      post :create, :project_id => @project.permalink, :page_id => @page.id, :note => {:name => 'Important!'}
      
      @page.notes(true).length.should == 1
    end
  end
  
  describe "#edit" do
    it "should redirect for html" do
      login_as @owner
      get :edit, :project_id => @project.permalink, :page_id => @page.id, :id => @note.id
      response.should be_redirect
    end
    
    it "should render for m" do
      login_as @owner
      get :edit, :project_id => @project.permalink, :page_id => @page.id, :id => @note.id, :format => 'm'
      response.should render_template('notes/edit')
    end
  end
end