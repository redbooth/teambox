require 'spec_helper'

describe ApiV1::ActivitiesController do
  before do
    @user = Factory.create(:confirmed_user)
    @project = Factory.create(:project)
    @owner = @project.user
    @project.add_user(@user)
    @other_project = Factory.create(:project)
    @other_project.add_user(@user)
  end
  
  describe "#index" do
    it "shows activities in all projects" do
      login_as @user
      
      get :index
      response.should be_success
      
      JSON.parse(response.body)['activities'].map{|a| a['id'].to_i}.sort.should == (@project.activity_ids+@other_project.activity_ids).sort
    end
    
    it "shows activities in a project" do
      login_as @user
      
      get :index, :project_id => @project.permalink
      response.should be_success
      
      JSON.parse(response.body)['activities'].map{|a| a['id'].to_i}.sort.should == @project.activity_ids.sort
    end
  end
  
  describe "#show" do
    it "shows an activity" do
      login_as @user
      
      activity = @project.activities.last
      
      get :show, :project_id => @project.permalink, :id => activity.id
      response.should be_success
      
      JSON.parse(response.body)['activity']['id'].should == activity.id.to_s
    end
  end
end