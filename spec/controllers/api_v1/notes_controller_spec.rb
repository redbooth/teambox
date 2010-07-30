require 'spec_helper'

describe ApiV1::NotesController do
  before do
    make_a_typical_project
    
    @page = @project.new_page(@owner, {:name => 'New Employee Information'})
    @page.save!
    
    @note = @page.build_note({:name => 'Office Ettiquete'}).tap do |n|
      n.updated_by = @owner
      @page.new_slot(0, true, n) if n.save
    end
  end
  
  describe "#index" do
    it "shows notes in a page" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :page_id => @page.id
      response.should be_success
      
      JSON.parse(response.body).length.should == 1
    end
  end
  
  describe "#show" do
    it "shows a note" do
      login_as @user
      
      get :show, :project_id => @project.permalink, :page_id => @page.id, :id => @note.id
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @note.id
    end
  end
  
  describe "#create" do
    it "should allow participants to create notes" do
      login_as @user
      
      post :create, :project_id => @project.permalink, :page_id => @page.id, :note => {:name => 'Important!'}
      response.should be_success
      
      @page.notes(true).length.should == 2
      @page.notes.last.name.should == 'Important!'
    end
    
    it "should not allow observers to create notes" do
      login_as @observer
      
      post :create, :project_id => @project.permalink, :page_id => @page.id, :note => {:name => 'Important!'}
      response.status.should == '401 Unauthorized'
      
      @page.notes(true).length.should == 1
    end
  end
  
  describe "#update" do
    it "should allow participants to modify a note" do
      login_as @user
      
      put :update, :project_id => @project.permalink, :page_id => @page.id, :id => @note.id, :note => {:name => 'Modified'}
      response.should be_success
      
      @note.reload.name.should == 'Modified'
    end
    
    it "should not allow observers to modify a note" do
      login_as @observer
      
      put :update, :project_id => @project.permalink, :page_id => @page.id, :id => @note.id, :note => {:name => 'Modified'}
      response.status.should == '401 Unauthorized'
      
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
      response.status.should == '401 Unauthorized'
      
      @page.notes(true).length.should == 1
    end
  end
end