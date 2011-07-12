require 'spec_helper'

describe ApiV1::AppLinksController do
  before do
    @user = Factory.create(:confirmed_user)
    @app_link = Factory.create(:app_link, :user => @user, :provider => 'google')
    @app_link2 = Factory.create(:app_link, :user => @user, :provider => 'twitter')
  end

  describe "#index" do
    it "shows app_links the user owns" do
      login_as @user

      get :index
      response.should be_success
      list = JSON.parse(response.body)
      list['type'].should == 'List'
      list['objects'].each {|o| o['type'].should == 'AppLink'}
      list['objects'].length.should == 2

      references = list['references'].map{|r| "#{r['id']}_#{r['type']}"}
      references.include?("#{@app_link.user_id}_User").should == true
      references.include?("#{@app_link2.user_id}_User").should == true
    end

    it "shows app_links with a JSONP callback" do
      login_as @user

      get :index, :callback => 'lolCat', :format => 'js'
      response.should be_success

      response.body.split('(')[0].should == 'lolCat'
    end

    it "shows app_links as JSON when requested with the :text format" do
      login_as @user

      get :index, :format => 'text'
      response.should be_success
      response.headers['Content-Type'][/text\/plain/].should_not be_nil
      list = JSON.parse(response.body)
      list['type'].should == 'List'
      list['objects'].each {|o| o['type'].should == 'AppLink'}
      list['objects'].length.should == 2
    end

    it "does not show app_links the user doesn't own" do
      login_as Factory(:confirmed_user)

      get :index
      response.should be_success
      JSON.parse(response.body)['objects'].length.should == 0
    end

    it "limits app_links" do
      login_as @user

      get :index, :count => 1
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 1
    end

    it "limits and offsets app_links" do
      login_as @user

      get :index, :since_id => @user.app_links.first.id, :count => 1
      response.should be_success

      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.should == [@user.app_links.last.id]
    end
  end

  describe "#create" do
    it "creates an app_link" do
      login_as @user

      app_link_attributes = Factory.attributes_for(:app_link,
        :provider => "facebook"
      )

      lambda {
        post :create, app_link_attributes
        response.status.should == 201
      }.should change(AppLink, :count)

      JSON.parse(response.body)['provider'].should == "facebook"
    end
  end

  describe "#show" do
    it "shows an app_link with references" do
      login_as @user

      get :show, :id => @app_link.id
      response.should be_success

      data = JSON.parse(response.body)
      data['type'].should == 'AppLink'
      data['id'].to_i.should == @app_link.id
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      references.include?("#{@app_link.user_id}_User").should == true
    end

    it "should not show an app_link that doesn't belong to the user" do
      @user2 = Factory.create(:confirmed_user)
      login_as @user2

      get :show, :id => @app_link.id
      response.status.should == 401

      JSON.parse(response.body)['errors']['type'].should == 'InsufficientPermissions'
    end

    it "should not show an app_link which does not exist" do
      login_as @user

      get :show, :id => 'omgffffuuuuu'

      response.status.should == 404

      JSON.parse(response.body)['errors']['type'].should == 'ObjectNotFound'
    end
  end

  describe "#destroy" do
    it "should destroy an app_link" do
      login_as @user

      AppLink.count.should == 2
      put :destroy, :id => @app_link.id
      response.should be_success
      AppLink.count.should == 1
    end

    it "should only allow the owner to destroy an app_link" do
      login_as @admin

      AppLink.count.should == 2
      put :destroy, :id => @app_link.id
      response.status.should == 401
      AppLink.count.should == 2
    end
  end

end
