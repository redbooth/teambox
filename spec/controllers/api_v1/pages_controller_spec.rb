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
      
      JSON.parse(response.body).length.should == 1
    end
    
    it "shows pages in all projects" do
      login_as @user
      
      other_project = Factory.create(:project)
      other_page = @project.new_page(other_project.user, {:name => 'Important plans!'})
      other_page.save!
      
      get :index
      response.should be_success
      
      JSON.parse(response.body).length.should == 2
    end
    
    it "limits and offsets pages" do
      login_as @user
      
      other_page = @project.new_page(@user, {:name => 'Phone numbers'})
      other_page.save!
      
      get :index, :project_id => @project.permalink, :since_id => @project.page_ids[1], :count => 1
      response.should be_success
      
      JSON.parse(response.body).map{|a| a['id'].to_i}.should == [@project.reload.page_ids[0]]
    end
  end
  
  describe "#show" do
    it "shows a page" do
      login_as @user
      
      get :show, :project_id => @project.permalink, :id => @page.id
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @page.id
    end
  end
  
  describe "#update" do
    it "should allow participants to modify the page" do
      login_as @user
      
      put :update, :project_id => @project.permalink, :id => @page.id, :page => {:name => 'Unimportant Plans'}
      response.should be_success
      
      @page.reload.name.should == 'Unimportant Plans'
    end
    
    it "should not allow non-participants to modify the page" do
      login_as @observer
      
      put :update, :project_id => @project.permalink, :id => @page.id, :page => {:name => 'Unimportant Plans'}
      response.status.should == '401 Unauthorized'
      
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
      response.status.should == '401 Unauthorized'
      
      @project.pages.length.should == 1
    end
  end
end