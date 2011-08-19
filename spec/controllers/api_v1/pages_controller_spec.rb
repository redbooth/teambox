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

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}

      data['objects'].length.should == 1
      references.include?("#{@project.id}_Project").should == true
      references.include?("#{@page.user_id}_User").should == true
    end

    it "includes references" do
      login_as @user

      get :index
      response.should be_success

      refs = JSON.parse(response.body)['references']
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

    it "shows no pages for archived projects" do
      login_as @user
      @project.update_attribute :archived, true

      get :index
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 0
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
    
    it "only shows private pages the user can see" do
      @page.is_private = true
      @page.save!
      
      @other_page = @project.new_page(@project.user, {:name => 'Secret plans!', :is_private => true})
      @other_page.save!
      
      login_as @user
      
      get :index, :project_id => @project.permalink
      response.should be_success
      
      data = JSON.parse(response.body)
      data['objects'].map{|o| o['id'].to_i}.should == [@page.id]
    end
  end

  describe "#show" do
    it "shows a page with references" do
      login_as @user

      @note = @page.build_note({:name => 'Office Ettiquete'}).tap do |n|
        n.updated_by = @user
        n.save
      end

      get :show, :project_id => @project.permalink, :id => @page.id
      response.should be_success

      page = JSON.parse(response.body)
      references = page['references'].map{|r| "#{r['id']}_#{r['type']}"}

      page['id'].to_i.should == @page.id
      references.include?("#{@note.id}_Note").should == true
      page['slots'][0]['rel_object_id'].should == @note.id

      references.include?("#{@project.id}_Project").should == true
      references.include?("#{@page.user_id}_User").should == true
    end
    
    it "does not show an unwatched private page" do
      @page.is_private = true
      @page.save!
      
      login_as @project.user
      
      get :show, :project_id => @project.permalink, :id => @page.id
      response.status.should == 401
    end
  end

  describe "#create" do
    it "should allow participants to create pages" do
      login_as @user

      post :create, :project_id => @project.permalink, :name => 'Important!'
      response.should be_success

      @project.pages.length.should == 2
      @project.pages.first.name.should == 'Important!'
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
    
    it "does not allow mystery users to update a private page" do
      @page.is_private = true
      @page.save!
      
      login_as @project.user
      
      get :update, :project_id => @project.permalink, :id => @page.id, :name => 'Unimportant Plans'
      response.status.should == 401
    end

    it "allows the creator to update the private_ids" do
      @page.is_private = true
      @page.save!

      login_as @page.user

      get :update, :project_id => @project.permalink, :id => @page.id, :is_private => true, :private_ids => [@owner.id]
      response.should be_ok

      @page.reload.watcher_ids.sort.should == [@owner.id, @page.user_id].sort
    end

    it "does not allow a watcher to update the private_ids" do
      @page.is_private = true
      @page.save!
      @page.add_watcher(@owner)

      login_as @owner

      get :update, :project_id => @project.permalink, :id => @page.id, :is_private => true, :private_ids => []
      response.status.should == 422

      @page.reload.watcher_ids.sort.should == [@owner.id, @page.user_id].sort
    end

    it "does not allow a stranger to update the private_ids" do
      @page.is_private = true
      @page.save!

      login_as @owner

      get :update, :project_id => @project.permalink, :id => @page.id, :is_private => true, :private_ids => [@owner.id]
      response.status.should == 401

      @page.reload.watcher_ids.sort.should == [@page.user_id].sort
    end
  end

  describe "#watch" do
    it "should allow participants to watch pages" do
      login_as @admin

      put :watch, :project_id => @project.permalink, :id => @page.id
      response.status.should == 200
    end
    
    it "should not allow participants to watch private pages" do
      @page.update_attribute(:is_private, true)
      login_as @admin

      put :watch, :project_id => @project.permalink, :id => @page.id
      response.status.should == 401
    end
  end

  describe "#unwatch" do
    it "should allow participants to uwatch pages" do
      login_as @user

      put :unwatch, :project_id => @project.permalink, :id => @page.id
      response.status.should == 200
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
