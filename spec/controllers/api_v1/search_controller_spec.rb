require 'spec_helper'

describe ApiV1::SearchController do
  describe "#results" do
    before do
      @user = login_as(:confirmed_user)
      @project = Factory.create :project, :user => @user, :permalink => 'important-project'
      @comment = Factory.create :comment, :project => @project
    end

    it "searches across all user's projects" do
      @results = mock('results', {:map => [@comment.to_api_hash], :reject! => [@comment.to_api_hash], :each => true})
      controller.stub!(:user_can_search?).and_return(true)

      p1 = @project
      p2 = Factory.create :project, :user => @user
      @results.stub!(:project).and_return(p2)

      ThinkingSphinx.should_receive(:search).
        with(*search_params([p1.id, p2.id])).and_return(@results)

      get :index, :q => 'important'
      response.should be_success
      JSON.parse(response.body)['objects'].length.should == 1

      assigns[:search_terms].should == 'important'
    end

    it "returns an empty array for blank searches" do
      controller.stub!(:user_can_search?).and_return(true)

      p1 = @project
      p2 = Factory.create :project, :user => @user

      get :index
      response.should be_success
      JSON.parse(response.body)['objects'].length.should == 0
    end

    it "rejects unauthorized search" do
      controller.stub!(:user_can_search?).and_return(false)

      get :index, :q => 'important'
      [501, 403].include?(response.status).should == true
    end

    it "searches in a single project" do
      person = Factory.create :person, :user => @user
      project = person.project
      comment = Factory.create :comment, :project => project

      @results = mock('results', {:map => [comment.to_api_hash], :reject! => [comment.to_api_hash], :each => true})
      @results.stub!(:project).and_return(project)
      controller.stub!(:user_can_search?).and_return(false)

      owner = project.user
      owner.stub!(:can_search?).and_return(true)
      controller.stub!(:project_owner).and_return(owner)

      ThinkingSphinx.should_receive(:search).
        with(*search_params(project.id)).and_return(@results)

      get :index, :q => 'important', :project_id => project.permalink
      response.should be_success
      JSON.parse(response.body)['objects'].length.should == 1
    end

    it "reject searching in unauthorized project" do
      project = Factory :project
      get :index, :q => 'important', :project_id => project.permalink
      response.status.should == 403 #belongs_to_project? filter
    end

    def search_params(project_ids)
      ['important', { :retry_stale => true, :order => 'updated_at DESC',
        :with => { :project_id => project_ids },
        :classes => [Conversation, Task, TaskList, Page],
        :page => nil}]
    end
  end
end
