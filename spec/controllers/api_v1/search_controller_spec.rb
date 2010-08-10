require 'spec_helper'

describe ApiV1::SearchController do
  describe "#results" do
    before do
      @user = login_as(:confirmed_user)
      @results = mock('results')
    end
    
    it "searches across all user's projects" do
      controller.stub!(:user_can_search?).and_return(true)
      
      p1 = Factory.create :project, :user => @user
      p2 = Factory.create :project, :user => @user
      
      Comment.should_receive(:search).
        with(*search_params([p1.id, p2.id])).and_return(@results)
      
      get :index, :q => 'important'
      response.should be_success
      
      assigns[:search_terms].should == 'important'
      assigns[:comments].should == @results
    end
    
    it "rejects unauthorized search" do
      controller.stub!(:user_can_search?).and_return(false)
      
      get :index, :q => 'important'
      ['501 Not Implemented', '403 Forbidden'].include?(response.status).should == true
    end
    
    it "searches in a single project" do
      controller.stub!(:user_can_search?).and_return(false)
      
      project = Factory.create :project, :permalink => 'important-project'
      Factory.create :person, :user => @user, :project => project
      owner = project.user
      owner.stub!(:can_search?).and_return(true)
      controller.stub!(:project_owner).and_return(owner)
      
      Comment.should_receive(:search).
        with(*search_params(project.id)).and_return(@results)
      
      get :index, :q => 'important', :project_id => project.permalink
      response.should be_success
      
      assigns[:comments].should == @results
    end
    
    it "reject searching in unauthorized project" do
      controller.stub!(:user_can_search?).and_return(false)
      
      project = Factory.create :project, :permalink => 'important-project'
      
      get :index, :q => 'important', :project_id => project.permalink
      response.status.should == '401 Unauthorized'
    end
    
    def search_params(project_ids)
      ['important', { :retry_stale => true, :order => 'created_at DESC',
        :with => { :project_id => project_ids },
        :page => nil}]
    end
  end
end