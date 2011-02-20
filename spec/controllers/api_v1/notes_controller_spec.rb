require 'spec_helper'

describe ApiV1::NotesController do
  before do
    make_a_typical_project
    
    @page = @project.new_page(@owner, {:name => 'New Employee Information'})
    @page.save!
    
    @note = @page.build_note({:name => 'Office Ettiquete'}).tap do |n|
      n.updated_by = @owner
      n.save
    end
  end
  
  describe "#index" do
    it "shows notes in a page" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :page_id => @page.id
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 1
    end
    
    it "shows all dividers without a page or project" do
      login_as @user
      
      get :index
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 1
    end
    
    it "returns references for linked objects" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :page_id => @page.id
      response.should be_success
      
      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      activities = data['objects']
      
      references.include?("#{@page.id}_Page").should == true
    end
  end
  
  describe "#show" do
    it "shows a note" do
      login_as @user
      
      get :show, :project_id => @project.permalink, :page_id => @page.id, :id => @note.id
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @note.id
    end
    
    it "shows a note without a page or project id" do
      login_as @user
      
      get :show, :id => @note.id
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @note.id
    end
  end
  
  describe "#create" do
    it "should allow participants to create notes" do
      login_as @user
      
      post :create, :project_id => @project.permalink, :page_id => @page.id, :name => 'Important!'
      response.should be_success
      
      @page.notes(true).length.should == 2
      @page.notes.last.name.should == 'Important!'
    end
    
    it "should insert notes at the top of a page" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :name => 'AT_TOP',
           :position => {:slot => 0, :before => true}
      response.should be_success
      
      @page.slots(true).first.rel_object.name.should == 'AT_TOP'
    end
    
    it "should insert notes at the footer of a page" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :name => 'AT_BOTTOM',
           :position => {:slot => -1}
      response.should be_success
      
      @page.slots(true).last.rel_object.name.should == 'AT_BOTTOM'
    end
    
    it "should insert notes before an existing widget" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :name => 'BEFORE',
           :position => {:slot => @note.page_slot.id, :before => 1}
      response.should be_success
      
      @page.slots(true)[0].rel_object.name.should == 'BEFORE'
    end
    
    it "should insert notes after an existing widget" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :name => 'AFTER',
           :position => {:slot => @note.page_slot.id, :before => 0}
      response.should be_success
      
      @page.slots(true)[1].rel_object.name.should == 'AFTER'
    end
    
    it "should not allow observers to create notes" do
      login_as @observer
      
      post :create, :project_id => @project.permalink, :page_id => @page.id, :name => 'Important!'
      response.status.should == 401
      
      @page.notes(true).length.should == 1
    end
  end
  
  describe "#update" do
    it "should allow participants to modify a note" do
      login_as @user
      
      put :update, :project_id => @project.permalink, :page_id => @page.id, :id => @note.id, :name => 'Modified'
      response.should be_success
      
      @note.reload.name.should == 'Modified'
    end
    
    it "should not allow observers to modify a note" do
      login_as @observer
      
      put :update, :project_id => @project.permalink, :page_id => @page.id, :id => @note.id, :name => 'Modified'
      response.status.should == 401
      
      @note.reload.name.should_not == 'Modified'
    end
  end
  
  describe "#destroy" do
    it "should allow participants to destroy a note" do
      login_as @user
      
      put :destroy, :project_id => @project.permalink, :page_id => @page.id, :id => @note.id
      response.should be_success
      
      @page.notes(true).length.should == 0
    end
    
    it "should not allow observers to destroy a note" do
      login_as @observer
      
      put :destroy, :project_id => @project.permalink, :page_id => @page.id, :id => @note.id
      response.status.should == 401
      
      @page.notes(true).length.should == 1
    end
  end
end