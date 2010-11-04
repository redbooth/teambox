require 'spec_helper'

describe ApiV1::ActivitiesController do
  before do
    make_a_typical_project
    
    @other_project = Factory.create(:project)
    @other_project.add_user(@user)
  end
  
  describe "#index" do
    it "shows activities in all projects" do
      login_as @user
      
      get :index
      response.should be_success
      
      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.sort.should == (@project.activity_ids+@other_project.activity_ids).sort
    end
    
    it "shows activities with a JSONP callback" do
      login_as @user
      
      get :index, :callback => 'lolCat', :format => 'js'
      response.should be_success
      
      response.body.split('(')[0].should == 'lolCat'
    end
    
    it "shows activities in a project" do
      login_as @user
      
      get :index, :project_id => @project.permalink
      response.should be_success
      
      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.sort.should == @project.activity_ids.sort
    end
    
    it "shows activities by a user" do
      login_as @user
      
      get :index, :user_id => @user.id
      response.should be_success
      
      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.sort.should == (Activity.find_all_by_user_id(@user.id).map(&:id)).sort
    end
    
    it "shows no activities for a ficticious user" do
      login_as @user
      
      get :index, :user_id => -1
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 0
    end
    
    it "limits activities" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :count => 1
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 1
    end
    
    it "limits and offsets activities" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :since_id => @project.activity_ids[1], :count => 1
      response.should be_success
      
      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.should == [@project.activity_ids[0]]
    end
    
    it "returns references for linked objects" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :since_id => @project.activity_ids[1], :count => 1
      response.should be_success
      
      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      data['objects'].should_not == nil
      
      references.include?("#{@project.id}_Project").should == true
      references.include?("#{@project.people.last.id}_Person").should == true
    end
  end
  
  describe "#show" do
    it "shows an activity" do
      login_as @user
      
      activity = @project.activities.last
      
      get :show, :project_id => @project.permalink, :id => activity.id
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == activity.id
    end
  end
end