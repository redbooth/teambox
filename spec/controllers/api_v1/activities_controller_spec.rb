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
      
      JSON.parse(response.body).map{|a| a['id'].to_i}.sort.should == (@project.activity_ids+@other_project.activity_ids).sort
    end
    
    it "shows activities in a project" do
      login_as @user
      
      get :index, :project_id => @project.permalink
      response.should be_success
      
      JSON.parse(response.body).map{|a| a['id'].to_i}.sort.should == @project.activity_ids.sort
    end
    
    it "limits and offsets activities" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :since_id => @project.activity_ids[1], :count => 1
      response.should be_success
      
      JSON.parse(response.body).map{|a| a['id'].to_i}.should == [@project.activity_ids[0]]
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