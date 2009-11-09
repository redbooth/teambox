ActionController::Routing::Routes.draw do |map|  
  map.logout            '/logout',              :controller => 'sessions',    :action => 'destroy'
  map.login             '/login',               :controller => 'sessions',    :action => 'new'
  map.register          '/register',            :controller => 'users',       :action => 'create'
  map.signup            '/signup',              :controller => 'users',       :action => 'new'
  map.settings          '/settings',            :controller => 'users',       :action => 'edit'
  map.welcome           '/welcome',             :controller => 'users',       :action => 'welcome'
  map.close_wecome_tab  '/close_welcome_tab',   :controller => 'users',       :action => 'close_welcome'
  map.forgot_password   '/forgot',              :controller => 'reset_passwords',   :action => 'new'
  map.reset_password    '/reset/:reset_code',   :controller => 'reset_passwords',   :action => 'reset'
  map.update_after_forgetting   '/forgetting',  :controller => 'reset_passwords',   :action => 'update_after_forgetting', :method => :put
  map.sent_password     '/reset_password_sent', :controller => 'reset_passwords',   :action => 'sent'
  
  map.resources :reset_passwords
  map.resource :session
  
  map.resources :users, :has_many => [:invitations], :member => { 
                          :unconfirmed_email => :get,
                          :confirm_email => :get,
                          :contact_importer => :get } do |user|

    user.resource  :avatar, :member => { :micro => :get, :thumb => :get, :profile => :get,:crop => :put }
    user.resources :conversations, :has_many => [:comments]
    user.resources :task_lists,    :has_many => [:comments]  do |task_lists|
      task_lists.resources :tasks, :has_many => [:comments]
    end
  end
  
  map.resources :projects,
      :has_many => [:pages, :people],
      :member => [:get_comments, :accept, :decline] do |project|
    #project.hours_by_month 'time_tracking/:year/:month', :controller => 'hours', :action => 'index', :conditions => { :method => :get }
    #project.time_tracking 'time_tracking', :controller => 'hours', :action => 'index'
    project.resources :invitations, :member => [:accept,:decline,:resend]
    
    project.resources :comments do |comment|
      comment.resources :uploads, :member => { :iframe => :get }
    end
    project.resources :uploads, :requirements => { :id => /[^\/]+/ }, :member => { :thumbnail => :get }

    map.reorder_task_lists 'project/:project_id/reorder_task_lists', :controller => 'task_lists', :action => 'reorder', :method => :post
    map.reorder_tasks 'project/:project_id/task_lists/:task_list_id/reorder_task_list', :controller => 'tasks', :action => 'reorder', :method => :post
    
    project.resources :task_lists, :has_many => [:comments], :collection => { :sortable => :get } do |task_lists|
      task_lists.resources :tasks, :has_many => [:comments], :member => { :check => :put, :uncheck => :put }
    end
    
    project.resources :people, :member => { :destroy => :get }
    project.resources :conversations, :has_many => [:comments,:uploads]
    project.resources :pages, :has_many => [:notes,:dividers,:task_list,:uploads]
  end
  
  map.resources :comments
  map.resources :task_lists, :only => [ :index ]
  map.resources :conversations, :only => [ :index ]
  map.resources :pages, :only => [ :index ]
  
  map.root :controller => 'projects', :action => 'index'
  
  SprocketsApplication.routes(map)
end
