require 'spec_helper'

describe ApiV1::PagesController do
  before do
    make_a_typical_project
    
    @page = @project.new_page(@user, {:name => 'Important plans!'})
    @page.save!
  end
  
  describe "#index" do
    it "shows pages in the project" do
      login_as @user
      
      get :index, :project_id => @project.permalink
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 1
    end
    
    it "includes references" do
      login_as @user
      
      get :index
      response.should be_success
      
      refs = JSON.parse(response.body)['references']
      refs.length.should == 2
      objtypes = refs.map {|r| r['type']}
      objtypes.include?('Project').should == true
      objtypes.include?('User').should == true
    end
    
    it "shows pages in all projects" do
      login_as @user
      
      project = Factory.create(:project)
      project.new_page(@user, {:name => 'Important plans!'}).save!
      project.add_user(@user)
      
      get :index
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 2
    end
    
    it "shows pages created by a user" do
      login_as @user
      
      get :index, :user_id => @user.id
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 1
    end
    
    it "shows no pages created by a ficticious user" do
      login_as @user
      
      get :index, :user_id => -1
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 0
    end
    
    it "limits pages" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :count => 1
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 1
    end
    
    it "limits and offsets pages" do
      login_as @user
      
      other_page = @project.new_page(@user, {:name => 'Phone numbers'})
      other_page.save!
      
      get :index, :project_id => @project.permalink, :since_id => @project.page_ids[1], :count => 1
      response.should be_success
      
      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.should == [@project.reload.page_ids[0]]
    end
    
    it "returns references for linked objects" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :since_id => @project.page_ids[1], :count => 1
      response.should be_success
      
      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      activities = data['objects']
      
      references.include?("#{@page.user_id}_User").should == true
    end
  end
  
  describe "#show" do
    it "shows a page" do
      login_as @user
      
      @note = @page.build_note({:name => 'Office Ettiquete'}).tap do |n|
        n.updated_by = @user
        n.save
      end
      
      get :show, :project_id => @project.permalink, :id => @page.id
      response.should be_success
      
      page = JSON.parse(response.body)
      page['id'].to_i.should == @page.id
      page['objects'][0]['type'].should == 'Note'
      page['slots'][0]['rel_object_id'].should == @note.id
    end
  end
  
  describe "#update" do
    it "should allow participants to modify the page" do
      login_as @user
      
      put :update, :project_id => @project.permalink, :id => @page.id, :name => 'Unimportant Plans'
      response.should be_success
      
      @page.reload.name.should == 'Unimportant Plans'
    end
    
    it "should not allow non-participants to modify the page" do
      login_as @observer
      
      put :update, :project_id => @project.permalink, :id => @page.id, :name => 'Unimportant Plans'
      response.status.should == 401
      
      @page.reload.name.should == 'Important plans!'
    end
  end
  
  describe "#destroy" do
    it "should allow participants to destroy the page" do
      login_as @user
      
      put :destroy, :project_id => @project.permalink, :id => @page.id
      response.should be_success
      
      @project.pages.length.should == 0
    end
    
    it "should not allow non-participants to destroy the page" do
      login_as @observer
      
      put :destroy, :project_id => @project.permalink, :id => @page.id
      response.status.should == 401
      
      @project.pages.length.should == 1
    end
  end
end