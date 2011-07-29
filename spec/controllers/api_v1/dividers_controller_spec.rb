require 'spec_helper'

describe ApiV1::DividersController do
  before do
    make_a_typical_project

    @page = @project.new_page(@owner, {:name => 'Divisions'})
    @page.save!

    @divider = @page.build_divider({:name => 'Drawing a line here'}).tap do |n|
      n.updated_by = @owner
      n.save
    end
  end

  describe "#index" do
    it "shows dividers in a page" do
      login_as @user

      get :index, :project_id => @project.permalink, :page_id => @page.id
      response.should be_success

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}

      data['objects'].length.should == 1
      references.include?("#{@divider.project_id}_Project").should == true
      references.include?("#{@divider.page_id}_Page").should == true
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

    it "does not show private dividers" do
      login_as @user
      @page.update_attribute(:is_private, true)

      get :index
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 0
    end
  end

  describe "#show" do
    it "shows a divider" do
      login_as @user

      get :show, :project_id => @project.permalink, :page_id => @page.id, :id => @divider.id
      response.should be_success

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}

      data['id'].to_i.should == @divider.id
      references.include?("#{@divider.project_id}_Project").should == true
      references.include?("#{@divider.page_id}_Page").should == true
    end

    it "shows a divider without a page or project id" do
      login_as @user

      get :show, :id => @divider.id
      response.should be_success

      JSON.parse(response.body)['id'].to_i.should == @divider.id
    end
  end

  describe "#create" do
    it "should allow participants to create dividers" do
      login_as @user

      post :create, :project_id => @project.permalink, :page_id => @page.id, :name => 'Divisions'
      response.should be_success

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}

      references.include?("#{@page.dividers.last.project_id}_Project").should == true
      references.include?("#{@page.dividers.last.page_slot.id}_PageSlot").should == true

      @page.dividers(true).length.should == 2
      @page.dividers.last.name.should == 'Divisions'
    end

    it "should insert dividers at the top of a page" do
      login_as @user

      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :name => 'AT_TOP',
           :position => {:slot => 0, :before => true}
      response.should be_success

      @page.slots(true).first.rel_object.name.should == 'AT_TOP'
    end

    it "should insert dividers at the footer of a page" do
      login_as @user

      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :name => 'AT_BOTTOM',
           :position => {:slot => -1}
      response.should be_success

      @page.slots(true).last.rel_object.name.should == 'AT_BOTTOM'
    end

    it "should insert dividers before an existing widget" do
      login_as @user

      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :name => 'BEFORE',
           :position => {:slot => @divider.page_slot.id, :before => 1}
      response.should be_success

      @page.slots(true)[0].rel_object.name.should == 'BEFORE'
    end

    it "should insert dividers after an existing widget" do
      login_as @user

      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :name => 'AFTER',
           :position => {:slot => @divider.page_slot.id, :before => 0}
      response.should be_success

      @page.slots(true)[1].rel_object.name.should == 'AFTER'
    end

    it "should not allow observers to create dividers" do
      login_as @observer

      post :create, :project_id => @project.permalink, :page_id => @page.id, :name => 'Divisions'
      response.status.should == 401

      @page.dividers(true).length.should == 1
    end
  end

  describe "#update" do
    it "should allow participants to modify a divider" do
      login_as @user

      put :update, :project_id => @project.permalink, :page_id => @page.id, :id => @divider.id, :name => 'Modified'
      response.should be_success
      
      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}

      references.include?("#{@divider.project_id}_Project").should == true
      references.include?("#{@divider.page_slot.id}_PageSlot").should == true

      @divider.reload.name.should == 'Modified'
    end

    it "should not allow observers to modify a divider" do
      login_as @observer

      put :update, :project_id => @project.permalink, :page_id => @page.id, :id => @divider.id, :name => 'Modified'
      response.status.should == 401

      @divider.reload.name.should_not == 'Modified'
    end
  end

  describe "#destroy" do
    it "should allow participants to destroy a divider" do
      login_as @user

      put :destroy, :project_id => @project.permalink, :page_id => @page.id, :id => @divider.id
      response.should be_success

      @page.dividers(true).length.should == 0
    end

    it "should not allow observers to destroy a divider" do
      login_as @observer

      put :destroy, :project_id => @project.permalink, :page_id => @page.id, :id => @divider.id
      response.status.should == 401

      @page.dividers(true).length.should == 1
    end
  end
end
