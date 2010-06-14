class HooksController < ApplicationController
  before_filter :find_hook, :only => [:edit, :update, :destroy]
  before_filter :can_modify?, :except => [:push]
  no_login_required :only => [:push]
  skip_before_filter :verify_authenticity_token, :only => [:push]

  def initialize
    @example_github_payload = <<-EOS
      {
        "before": "5aef35982fb2d34e9d9d4502f6ede1072793222d",
        "repository": {
          "url": "http://github.com/defunkt/github",
          "name": "github",
          "description": "You're lookin' at it.",
          "watchers": 5,
          "forks": 2,
          "private": 1,
          "owner": {
            "email": "chris@ozmm.org",
            "name": "defunkt"
          }
        },
        "commits": [
          {
            "id": "41a212ee83ca127e3c8cf465891ab7216a705f59",
            "url": "http://github.com/defunkt/github/commit/41a212ee83ca127e3c8cf465891ab7216a705f59",
            "author": {
              "email": "chris@ozmm.org",
              "name": "Chris Wanstrath"
            },
            "message": "okay i give in",
            "timestamp": "2008-02-15T14:57:17-08:00",
            "added": ["filepath.rb"]
          },
          {
            "id": "de8251ff97ee194a289832576287d6f8ad74e3d0",
            "url": "http://github.com/defunkt/github/commit/de8251ff97ee194a289832576287d6f8ad74e3d0",
            "author": {
              "email": "chris@ozmm.org",
              "name": "Chris Wanstrath"
            },
            "message": "update pricing a tad",
            "timestamp": "2008-02-15T14:36:34-08:00"
          }
        ],
        "after": "de8251ff97ee194a289832576287d6f8ad74e3d0",
        "ref": "refs/heads/master"
      }
    EOS
  end
  
  def index
    @hooks = @current_user.hooks
  end
    
  def new
    @hook = @current_user.hooks.build
  end
  
  def edit
  end
  
  def update
    respond_to do |f|
      if @hook.update_attributes(params[:hook])
        f.html { redirect_to edit_project_hook_path(@current_project, @hook) }
      else
        f.html { render :edit }
      end
    end
  end
  
  def create
    @hook = @current_user.hooks.build(params[:hook])
    @hook.project = @current_project
    
    respond_to do |f|
      if @hook.save
        f.html { redirect_to project_hooks_path(@current_project) }
      else
        f.html { render :edit }
      end
    end
  end
  
  def destroy
    respond_to do |f|
      if @hook.destroy
        flash[:success] = t('hooks.destroy.success', :hook => @hook.name)
      end
      f.html { redirect_to project_hooks_path(@current_project) }
    end
  end
  
  def push    
    if @hook = Hook.find(:first, :conditions => {:key => params[:key]})
      params.merge!({:payload => @example_github_payload}) unless params[:payload]
    
      post = parse_data
      template = params[:template] || @hook.message
    
      if create_comment(template, post)
        render :text => "OK"
      end
    end
  end
  
  protected

    def parse_data
      post = {:hook_time => Time.now.to_s}
      params.each do |k,v|
        begin
          case params[:format]
          when 'xml'  then data = XML.parse(v)
          when 'json' then data = JSON.parse(v)
          else data = v
          end
          post.merge!({k => data})
        rescue
          # we might want to notify @hook.user with an email?
          # If its not xml/json, just take the raw param
          post.merge!({k => v})
        end unless ['controller','key','action','method','format', 'template'].include?(k)
      end
      
      post
    end

    def create_comment(template, post)
      text = RDiscount.new(Mustache.render(template, post)).to_html
      
      @hook.project.new_comment(@hook.user, @hook.project, {
        :body => "<div class='hook'>#{text}</div>",
        :user => @hook.user}).save!
    end
    
    def find_hook
      @hook = @current_user.hooks.find_by_id(params[:id])
    end
    
    def can_modify?
      if !(@current_project.owner?(current_user) or @current_project.admin?(current_user))
          respond_to do |f|
            flash[:error] = t('common.not_allowed')
            f.html { redirect_to projects_path }
            handle_api_error(f, @current_project)
          end
        return false
      end
      
      true
    end
end