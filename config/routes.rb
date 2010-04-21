ActionController::Routing::Routes.draw do |map|
  map.resources :sprockets, :only => [:index, :show]
  
  map.logout            '/logout',              :controller => 'sessions',    :action => 'destroy'
  map.login             '/login',               :controller => 'sessions',    :action => 'new'
  map.register          '/register',            :controller => 'users',       :action => 'create'
  map.signup            '/signup',              :controller => 'users',       :action => 'new'

  map.welcome           '/welcome',             :controller => 'users',       :action => 'welcome'
  map.close_wecome_tab  '/close_welcome_tab',   :controller => 'users',       :action => 'close_welcome'
  map.forgot_password   '/forgot',              :controller => 'reset_passwords',   :action => 'new'
  map.reset_password    '/reset/:reset_code',   :controller => 'reset_passwords',   :action => 'reset'
  map.update_after_forgetting   '/forgetting',  :controller => 'reset_passwords',   :action => 'update_after_forgetting', :method => :put
  map.sent_password     '/reset_password_sent', :controller => 'reset_passwords',   :action => 'sent'

  map.new_example_project    '/example/new',    :controller => 'example_projects', :action => 'new'
  map.create_example_project '/example/create', :controller => 'example_projects', :action => 'create'

  map.create_project_invitation '/projects/:project_id/invite/:login', :controller => 'invitations', :action => 'create', :method => :post

  map.resources :reset_passwords
  map.resource :session

  map.account_settings '/account/settings', :controller => 'users', :action => 'edit', :sub_action => 'settings'
  map.account_picture '/account/picture',   :controller => 'users', :action => 'edit', :sub_action => 'picture'
  map.account_profile '/account/profile',   :controller => 'users', :action => 'edit', :sub_action => 'profile'
  map.account_notifications '/account/notifications', :controller => 'users', :action => 'edit', :sub_action => 'notifications'

  map.resources :users, :has_many => [:invitations,:comments], :member => {
                          :unconfirmed_email => :get,
                          :confirm_email => :get,
                          :contact_importer => :get } do |user|

    user.resources :conversations, :has_many => [:comments]
    user.resources :task_lists,    :has_many => [:comments]  do |task_lists|
      task_lists.resources :tasks, :has_many => [:comments]
    end
  end

  map.activities 'activities.:format',               :controller => 'activities', :action => 'show',      :method => :get
  map.show_new   'activities/:id/show_new.:format',  :controller => 'activities', :action => 'show_new',  :method => :get
  map.show_more  'activities/:id/show_more.:format', :controller => 'activities', :action => 'show_more', :method => :get

  map.project_archived 'projects/archived.:format',  :controller => 'projects', :action => 'index', :sub_action => 'archived'

  map.resources :projects,
      :has_many => [:pages, :people],
      :member => {:get_comments => :get, :accept => :post, :decline => :post, :transfer => :put} do |project|
    project.hours_by_month 'time/:year/:month', :controller => 'hours', :action => 'index', :conditions => { :method => :get }
    project.time 'time', :controller => 'hours', :action => 'index'

    project.settings 'settings',  :controller => 'projects', :action => 'edit', :sub_action => 'settings'
    project.picture  'picture',   :controller => 'projects', :action => 'edit', :sub_action => 'picture'
    project.deletion 'deletion',  :controller => 'projects', :action => 'edit', :sub_action => 'deletion'
    project.ownership 'ownership', :controller => 'projects', :action => 'edit', :sub_action => 'ownership'

    project.my_task_lists 'my_task_lists',             :controller => 'task_lists', :action => 'index', :sub_action => 'mine'
    project.archived_task_lists 'task_lists/archived', :controller => 'task_lists', :action => 'index', :sub_action => 'archived'

    project.resources :invitations, :member => [:accept,:decline,:resend]

    project.resources :comments do |comment|
      comment.resources :uploads, :member => { :iframe => :get }
    end

    project.activities 'activities.:format',               :controller => 'activities', :action => 'show',      :method => :get
    project.show_new   'activities/:id/show_new.:format',  :controller => 'activities', :action => 'show_new',  :method => :get
    project.show_more  'activities/:id/show_more.:format', :controller => 'activities', :action => 'show_more', :method => :get

    project.resources :uploads

    project.reorder_task_lists 'reorder_task_lists', :controller => 'task_lists', :action => 'reorder', :method => :post
    project.reorder_tasks 'task_lists/:task_list_id/reorder_task_list', :controller => 'tasks', :action => 'reorder', :method => :post

    project.resources :task_lists, :has_many => [:comments], :collection => { :sortable => :get, :archived => :get  }, :member => [:archive,:unarchive,:watch,:unwatch] do |task_lists|
        task_lists.resources :tasks, :has_many => [:comments], :member => { :watch => :post, :unwatch => :post, :archive => :put, :unarchive => :put, :reopen => :get, :show_in_main_content => :get }
    end
    
    project.contacts 'contacts', :controller => :people, :action => :contacts, :method => :get
    project.resources :people, :member => { :destroy => :get }
    project.resources :conversations, :has_many => [:comments,:uploads], :member => [:watch,:unwatch]
    project.resources :pages, :has_many => [:notes,:dividers,:task_list,:uploads], :member => { :reorder => :post }
  end
  
  map.resources :groups, :member => { :logo => :any, :projects => :any, :members => :any} do |group|
    group.resources :invitations, :member => [:accept,:decline,:resend]
  end
  
  # map.resources :comments
  map.resources :task_lists, :only => [ :index ]
  # map.resources :conversations, :only => [ :index ]
  # map.resources :pages, :only => [ :index ]

  map.root :controller => 'projects', :action => 'index'
  map.connect 'assets/:id/:style/:filename', :controller => 'uploads', :action => 'download', :conditions => { :method => :get }, :requirements => { :filename => /.*/ }
end
