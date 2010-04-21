class ConversationsController < ApplicationController
  before_filter :load_conversation, :only => [:show,:edit,:update,:destroy,:update_comments,:watch,:unwatch]
  before_filter :check_permissions, :only => [:new,:create,:edit,:update,:destroy]
  before_filter :set_page_title

  def new
    @conversation = @current_project.conversations.new
  end

  def create
    @conversation = @current_project.new_conversation(current_user,params[:conversation])
    @conversation.body = params[:conversation][:body]

    if @conversation.save
      if (params[:user_all] || 0).to_i == 1
        @conversation.add_watchers @current_project.users
      else
        add_watchers params[:user]
      end
      @conversation.notify_new_comment(@conversation.comments.first)
      
      respond_to do |f|
        f.html { redirect_to project_conversation_path(@current_project,@conversation) }
        f.xml  { redirect_to project_conversation_path(@current_project,@conversation) }
        f.json { redirect_to project_conversation_path(@current_project,@conversation) }
        f.yaml { redirect_to project_conversation_path(@current_project,@conversation) }
      end
    else
      respond_to do |f|
        f.html  { render :action => :new }
        f.xml   { render :xml => @conversation.errors.to_xml }
        f.json  { render :as_json => @conversation.errors.to_xml }
        f.yaml  { render :as_yaml => @conversation.errors.to_xml }
      end
    end
  end

  def index
    @conversations = @current_project.conversations

    respond_to do |f|
      f.html
      f.m
      f.rss   { render :layout => false }
      f.xml   { render :xml     => @conversations.to_xml }
      f.json  { render :as_json => @conversations.to_xml }
      f.yaml  { render :as_yaml => @conversations.to_xml }
    end
  end

  def show
    @comments = @conversation.comments
    @conversations = @current_project.conversations

    respond_to do |f|
      f.html
      f.m
      f.xml   { render :xml     => @conversation.to_xml(:include => :comments) }
      f.json  { render :as_json => @conversation.to_xml(:include => :comments) }
      f.yaml  { render :as_yaml => @conversation.to_xml(:include => :comments) }
    end

#   Use this snippet to test the notification emails that we send:
#    @project = @current_project
#    render :file => 'emailer/notify_conversation', :layout => false
  end

  def update
    @conversation.update_attributes(params[:conversation])
    respond_to do |f|
      f.js
      f.m    { redirect_to project_conversation_path(@current_project, @conversation) }
      f.html { redirect_to project_conversation_path(@current_project, @conversation) }
    end
  end

  def destroy
    if @conversation.editable?(current_user)
      @conversation.try(:destroy)

      respond_to do |f|
        f.html do
          flash[:success] = t('deleted.conversation', :name => @conversation.to_s)
          redirect_to project_conversations_path(@current_project)
        end
        f.m { redirect_to project_conversations_path(@current_project) }
        f.js
      end
    else
      respond_to do |f|
        flash[:error] = t('common.not_allowed')
        f.html { redirect_to project_conversation_path(@current_project, @conversation) }
        f.m    { redirect_to project_conversation_path(@current_project, @conversation) }
        f.js   { render :text => 'alert("Not allowed!");'; }
      end
    end
  end

  def watch
    @conversation.add_watcher(current_user)
    respond_to do |f|
      f.js
      f.m    { redirect_to project_conversation_path(@current_project, @conversation) }
      f.html { redirect_to project_conversation_path(@current_project, @conversation) }
    end
  end

  def unwatch
    @conversation.remove_watcher(current_user)
    respond_to do |f|
      f.js
      f.m    { redirect_to project_conversation_path(@current_project, @conversation) }
      f.html { redirect_to project_conversation_path(@current_project, @conversation) }
    end
  end

  private
    def load_conversation
      begin
        @conversation = @current_project.conversations.find(params[:id])
      rescue
        flash[:error] = t('not_found.conversation', :id => h(params[:id]))
      end
      
      redirect_to project_path(@current_project) unless @conversation
    end

    def add_watchers(hash)
      (hash || []).each do |user_id, should_notify|
        if should_notify == "1" and Person.exists? :project_id => @conversation.project_id, :user_id => user_id
          user = User.find user_id
          @conversation.add_watcher user# if user
        end
      end
    end
end