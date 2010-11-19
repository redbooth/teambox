class IntegrationsController < ApplicationController
  before_filter :find_hook, :only => [:edit, :update, :destroy]
  before_filter :find_templates, :only => [:index, :new]
  before_filter :can_modify?, :except => [:notify]
  before_filter :target, :only => [:push]
  no_login_required :only => [:notify]
  skip_before_filter :verify_authenticity_token, :only => [:notify]

  def index
    @hooks = @current_user.hooks
  end

  def new
    @hook = Hook.new do |hook|
      hook.user = @current_user
      if @templates.include?(params[:template])
        hook.name = params[:template].titleize
        hook.message = open("#{Rails.root}/app/views/integrations/templates/#{params[:template]}.tpl").read
        @template_readme = RDiscount.new(open("#{Rails.root}/app/views/integrations/templates/#{params[:template]}.readme").read).to_html
      end
    end
  end

  def edit
  end

  def update
    respond_to do |f|
      if @hook.update_attributes(params[:hook])
        f.html { redirect_to edit_project_integration_path(@current_project, @hook) }
      else
        f.html { render :edit }
      end
    end
  end

  def create
    @hook = @current_user.hooks.new(params[:hook])
    @hook.project = @current_project
    
    respond_to do |f|
      if @hook.save
        f.html { redirect_to edit_project_integration_path(@current_project,@hook) }
      else
        f.html { render :edit }
      end
    end
  end
  
  def destroy
    respond_to do |f|
      if @hook.destroy
        flash[:success] = t('integrations.destroy.success', :hook => @hook.name)
      end
      f.html { redirect_to project_integrations_path(@current_project) }
    end
  end

  def notify
    if @hook = Hook.find_by_token(params[:token])
      post = parse_data
      template = params[:template] || @hook.message

      render :text => "OK", :status => create_thread(template, post)
    end
  end

  protected
    def parse_data
      post = {:hook_time => Time.now.to_s}
      params.each do |k,v|
        begin
          case params[:format]
          when 'xml'  then data = Crack::XML.parse(v)
          when 'json' then data = JSON.parse(v)
          else data = v
          end
          post.merge!({k => data})
        rescue
          # we might want to notify @hook.user with an email?
          # If its not xml/json, just take the raw param
          post.merge!({k => v})
        end unless %w(controller key action method format template).include?(k)
      end
      
      post
    end

    def create_thread(template, post)
      text = RDiscount.new(Mustache.render(template, post)).to_html
      @comment = @hook.project.conversations.new_by_user(@hook.user, :body => text, :simple => true )

      if @comment.save
        200
      else
        406
      end
    end

    def find_hook
      @hook = @current_user.hooks.find_by_id(params[:id])
    end

    def find_templates
      @templates = []
      Dir.glob("#{Rails.root}/app/views/integrations/templates/*.tpl") do |file|
        @templates << File.basename(file, ".tpl")
      end
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