ActionController::Routing::Routes.draw do |map|  
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
  
  map.resources :reset_passwords
  map.resource :session

  map.project_my_task_lists '/projects/:project_id/my_task_lists/', :controller => 'task_lists', :action => 'index', :sub_action => 'mine'
  map.project_archived_task_lists '/projects/:project_id/task_lists/archived', :controller => 'task_lists', :action => 'index', :sub_action => 'archived'

  map.account_settings '/account/settings', :controller => 'users', :action => 'edit', :sub_action => 'settings'
  map.account_picture '/account/picture', :controller => 'users', :action => 'edit', :sub_action => 'picture'
  map.account_profile '/account/profile', :controller => 'users', :action => 'edit', :sub_action => 'profile'
  map.account_notifications '/account/notications', :controller => 'users', :action => 'edit', :sub_action => 'notifications'
  
  map.resources :users, :has_many => [:invitations,:comments], :member => { 
                          :unconfirmed_email => :get,
                          :confirm_email => :get,
                          :contact_importer => :get } do |user|

    user.resources :conversations, :has_many => [:comments]
    user.resources :task_lists,    :has_many => [:comments]  do |task_lists|
      task_lists.resources :tasks, :has_many => [:comments]
    end
  end

  map.show_more 'activities/:id/show_more', :controller => 'activities', :action => 'show_more', :method => :get
  
  map.resources :projects,
      :has_many => [:pages, :people],
      :member => [:get_comments, :accept, :decline] do |project|
    #project.hours_by_month 'time_tracking/:year/:month', :controller => 'hours', :action => 'index', :conditions => { :method => :get }
    #project.time_tracking 'time_tracking', :controller => 'hours', :action => 'index'
    project.resources :invitations, :member => [:accept,:decline,:resend]
        
    project.resources :comments do |comment|
      comment.resources :uploads, :member => { :iframe => :get }
    end

    project.show_more 'activities/:id/show_more', :controller => 'activities', :action => 'show_more', :method => :get

    project.resources :uploads

    project.reorder_task_lists 'reorder_task_lists', :controller => 'task_lists', :action => 'reorder', :method => :post
    project.reorder_tasks 'task_lists/:task_list_id/reorder_task_list', :controller => 'tasks', :action => 'reorder', :method => :post
    
    project.resources :task_lists, :has_many => [:comments], :collection => { :sortable => :get, :archived => :get  }, :member => [:watch,:unwatch] do |task_lists|
        task_lists.resources :tasks, :has_many => [:comments], :member => { :watch => :post, :unwatch => :post, :archive => :put, :unarchive => :put  }
    end
    
    project.resources :people, :member => { :destroy => :get }
    project.resources :conversations, :has_many => [:comments,:uploads], :member => [:watch,:unwatch]
    project.resources :pages, :has_many => [:notes,:dividers,:task_list,:uploads]
  end
  
  map.resources :comments
  map.resources :task_lists, :only => [ :index ]
  map.resources :conversations, :only => [ :index ]
  map.resources :pages, :only => [ :index ]
  
  map.root :controller => 'projects', :action => 'index'
  map.connect 'assets/:id/:style/:basename.:format', :controller => 'uploads', :action => 'download', :conditions => { :method => :get } #:requirements => { :basename => /.*/ }
  map.connect 'assets/:id/:style/:basename', :controller => 'uploads', :action => 'download', :conditions => { :method => :get }  
  SprocketsApplication.routes(map)
end
