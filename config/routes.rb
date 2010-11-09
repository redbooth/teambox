ActionController::Routing::Routes.draw do |map|
  map.resources :sprockets, :only => [:index, :show]
  
  map.logout            '/logout',              :controller => 'sessions',    :action => 'destroy'
  map.login             '/login',               :controller => 'sessions',    :action => 'new'
  map.login_backdoor    '/login/:username',     :controller => 'sessions',    :action => 'backdoor' if Rails.env.cucumber?
  
  map.register          '/register',            :controller => 'users',       :action => 'create'
  map.signup            '/signup',              :controller => 'users',       :action => 'new'
  
  map.search            '/search',              :controller => 'search'

  map.text_styles       '/text_styles',         :controller => 'users',       :action => 'text_styles'
  map.invite_format     '/invite_format',       :controller => 'invitations', :action => 'invite_format'
  map.feeds             '/feeds',               :controller => 'users',       :action => 'feeds'
  map.calendars         '/calendars',           :controller => 'users',       :action => 'calendars'
  map.disable_splash    '/disable_splash',      :controller => 'users',       :action => 'disable_splash'
  map.forgot_password   '/forgot',              :controller => 'reset_passwords',   :action => 'new'
  map.reset_password    '/reset/:reset_code',   :controller => 'reset_passwords',   :action => 'reset'
  map.update_after_forgetting   '/forgetting',  :controller => 'reset_passwords',   :action => 'update_after_forgetting', :method => :put
  map.sent_password     '/reset_password_sent', :controller => 'reset_passwords',   :action => 'sent'

  map.change_format     '/format/:f',           :controller => 'sessions',    :action => 'change_format'

  map.create_project_invitation '/projects/:project_id/invite/:login', :controller => 'invitations', :action => 'create', :method => :posts

  map.auth_callback  '/auth/:provider/callback', :controller => 'auth', :action => 'callback'
  map.auth_failure   '/auth/failure', :controller => 'auth', :action => 'failure'
  map.complete_signup '/complete_signup',          :controller => 'users', :action => 'complete_signup'
  map.unlink_app      '/auth/:provider/unlink',   :controller => 'users', :action => 'unlink_app'

  map.javascript_environment '/i18n/environment.js', :controller => 'javascripts', :action => 'environment'

  map.resources :reset_passwords
  map.resource :session
  map.resources :organizations, :member => [:projects, :external_view, :delete] do |org|
    org.resources :memberships, :member => [:change_role, :add, :remove]
  end

  map.resources :sites, :only => [:show, :new, :create]

  map.with_options :controller => 'users', :action => 'edit' do |account|
    account.account_settings        '/account/settings',        :sub_action => 'settings'
    account.account_picture         '/account/picture',         :sub_action => 'picture'
    account.account_profile         '/account/profile',         :sub_action => 'profile'
    account.account_linked_accounts '/account/linked_accounts', :sub_action => 'linked_accounts'
    account.account_notifications   '/account/notifications',   :sub_action => 'notifications'
    account.account_delete          '/account/delete',          :sub_action => 'delete'
  end

  map.destroy_user '/account/destroy', :controller => 'users', :action => 'destroy'

  map.resources :users, :has_many => [:invitations], :member => {
                          :unconfirmed_email => :get,
                          :confirm_email => :get,
                          :contact_importer => :get } do |user|

    user.resources :conversations
    user.resources :task_lists do |task_lists|
      task_lists.resources :tasks
    end
    
    user.show_more   'activities/users/:id/show_more.:format',  :controller => 'activities', :action => 'show_more',  :method => :get
  end

  map.activities 'activities.:format',               :controller => 'activities', :action => 'show',      :method => :get
  map.show_new   'activities/:id/show_new.:format',  :controller => 'activities', :action => 'show_new',  :method => :get
  map.show_more  'activities/:id/show_more.:format', :controller => 'activities', :action => 'show_more', :method => :get
  map.show_thread  'activities/:id/show_thread.:format', :controller => 'activities', :action => 'show_thread', :method => :get

  map.project_archived 'projects/archived.:format',  :controller => 'projects', :action => 'index', :sub_action => 'archived'

  map.hooks 'hooks/:hook_name', :controller => 'hooks', :action => 'create', :conditions => { :method => :post }

  map.resources :projects,
      :has_many => [:pages, :people],
      :member => {:accept => :post, :decline => :post, :transfer => :put, :join => :get} do |project|
    project.hours_by_month 'time/:year/:month', :controller => 'hours', :action => 'index', :conditions => { :method => :get }
    project.hours_by_period 'time/by_period', :controller => 'hours', :action => 'by_period', :conditions => { :method => :get }
    project.time 'time', :controller => 'hours', :action => 'index'

    project.settings 'settings',  :controller => 'projects', :action => 'edit', :sub_action => 'settings'
    project.picture  'picture',   :controller => 'projects', :action => 'edit', :sub_action => 'picture'
    project.deletion 'deletion',  :controller => 'projects', :action => 'edit', :sub_action => 'deletion'
    project.ownership 'ownership', :controller => 'projects', :action => 'edit', :sub_action => 'ownership'

    project.resources :invitations, :member => [:accept,:decline,:resend]

    project.activities 'activities.:format',               :controller => 'activities', :action => 'show',      :method => :get
    project.show_new   'activities/:id/show_new.:format',  :controller => 'activities', :action => 'show_new',  :method => :get
    project.show_more  'activities/:id/show_more.:format', :controller => 'activities', :action => 'show_more', :method => :get

    project.resources :uploads

    project.hooks 'hooks/:hook_name', :controller => 'hooks', :action => 'create', :conditions => { :method => :post }

    # Use routes for /project/:project_id/tasks instead of /project/:project_id/task_lists/:task_list_id/tasks
    project.resources :tasks, :has_many => :comments, :member => { :watch => :put, :unwatch => :put, :reorder => :put }

    project.resources :task_lists,
      :collection => { :gantt_view => :get, :archived => :get, :reorder => :put },
      :member => { :watch => :put, :unwatch => :put, :archive => :put, :unarchive => :put } do |task_lists|
        # deprecated routes, use "project.resources :tasks" directly
        task_lists.resources :tasks, :has_many => :comments, :member => { :watch => :put, :unwatch => :put }
    end

    project.contacts 'contacts', :controller => :people, :action => :contacts, :method => :get
    project.resources :people, :member => { :destroy => :get }
    project.resources :conversations, :has_many => [:comments], :member => { :watch => :put, :unwatch => :put }
    project.resources :pages, :has_many => [:notes,:dividers,:task_list,:uploads], :member => { :reorder => :post }, :collection => { :resort => :post }
    
    project.search 'search', :controller => 'search'
  end
  
  map.public_projects '/public', :controller => 'public/projects', :action => :index

  map.namespace(:public) do |p|
    p.project ':id', :controller => 'projects', :action => :show
    p.project_conversations ':project_id/conversations',     :controller => 'conversations', :action => :index
    p.project_conversation  ':project_id/conversations/:id', :controller => 'conversations', :action => :show
    p.project_page          ':project_id/:id',       :controller => 'pages', :action => :show
  end

  map.with_options :controller => 'apidocs' do |doc|
    doc.api           'api',          :action => 'index'
    doc.api_concepts  'api/concepts', :action => 'concepts'
    doc.api_routes    'api/routes',   :action => 'routes'
    doc.api_changes   'api/changes',   :action => 'changes'
    doc.api_model     'api/:model',   :action => 'model'
  end
  
  map.namespace(:api_v1, :path_prefix => 'api/1') do |api|
    api.resources :projects, :except => [:new, :edit], :member => {:transfer => :put} do |project|
      project.resources :activities, :only => [:index, :show]
      project.resources :people, :except => [:create, :new, :edit]
      project.resources :comments, :except => [:new, :create, :edit]
      project.resources :conversations, :except => [:new, :edit], :member => {:watch => :put, :unwatch => :put} do |conversation|
        conversation.resources :comments, :except => [:new, :edit]
      end
      project.resources :invitations, :except => [:new, :edit, :update], :member => {:resend => :put}
      project.resources :task_lists, :except => [:new, :edit], :member => {:archive => :put, :unarchive => :put} do |task_list|
        task_list.resources :tasks, :except => [:new, :edit]
      end
      project.resources :tasks, :except => [:new, :edit, :create], :member => {:watch => :put, :unwatch => :put}  do |task|
        task.resources :comments, :except => [:new, :edit]
      end
      project.resources :uploads, :except => [:new, :edit, :update]
      project.resources :pages, :except => [:new, :edit], :member => {:reorder => :put}, :collection => {:resort => :put}
      project.resources :notes, :except => [:new, :edit]
      project.resources :dividers, :except => [:new, :edit]
      project.search 'search', :controller => 'search'
    end
    api.resources :activities, :only => [:index, :show]
    api.resources :invitations, :except => [:new, :edit, :update, :create], :member => {:accept => :put}
    api.resources :users, :only => [:index, :show]
    
    
    api.resources :tasks, :except => [:new, :edit, :create], :member => {:watch => :put, :unwatch => :put}
    api.resources :comments, :except => [:new, :create, :edit]
    api.resources :conversations, :except => [:new, :edit], :member => {:watch => :put, :unwatch => :put} do |conversation|
      conversation.resources :comments, :except => [:new, :edit]
    end
    api.resources :task_lists, :except => [:new, :edit], :member => {:archive => :put, :unarchive => :put} do |task_list|
      task_list.resources :tasks, :except => [:new, :edit]
    end
    api.resources :tasks, :except => [:new, :edit, :create], :member => {:watch => :put, :unwatch => :put}  do |task|
      task.resources :comments, :except => [:new, :edit]
    end
    api.resources :uploads, :except => [:new, :edit, :update]
    api.resources :pages, :except => [:new, :edit], :member => {:reorder => :put}, :collection => {:resort => :put}
    api.resources :notes, :except => [:new, :edit]
    api.resources :dividers, :except => [:new, :edit]
    
    api.resources :organizations, :except => [:new, :edit, :destroy] do |organization|
      organization.resources :projects, :except => [:new, :edit], :member => {:transfer => :put}
      organization.resources :memberships, :except => [:new, :edit, :create]
    end
    
    api.search 'search', :controller => 'search'
    api.account 'account', :controller => :users, :action => :current, :conditions => { :method => :get }
  end
  
  map.resources :task_lists, :only => [ :index ], :collection => { :gantt_view => :get }
  map.resources :conversations, :only => [ :create ]
  # map.resources :pages, :only => [ :index ]

  map.hours_by_month 'time/:year/:month', :controller => 'hours', :action => 'index', :conditions => { :method => :get }
  map.hours_by_period 'time/by_period', :controller => 'hours', :action => 'by_period', :conditions => { :method => :get }
  map.time 'time', :controller => 'hours', :action => 'index'

  map.root :controller => 'projects', :action => 'index'
  map.connect 'assets/:id/:style/:filename', :controller => 'uploads', :action => 'download', :conditions => { :method => :get }, :requirements => { :filename => /.*/ }
end
