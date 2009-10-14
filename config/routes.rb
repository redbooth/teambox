ActionController::Routing::Routes.draw do |map|  
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.settings '/settings', :controller => 'users', :action => 'edit'
  map.welcome '/welcome', :controller => 'users', :action => 'welcome'
  map.close_wecome_tab '/close_welcome_tab', :controller => 'users', :action => 'close_welcome'
  map.resource :session
  
  map.resources :users, :has_many => [:invitations], :member => { 
                          :comments_descending => :put, 
                          :comments_ascending => :put,
                          :conversations_first_comment => :put,
                          :conversations_latest_comment => :put,
                          :contact_importer => :get } do |user|

    user.resources :task_lists, :has_many => [:comments] do |task_lists|
      task_lists.resources :tasks, :has_many => [:comments], :member => { :check => :put, :uncheck => :put }
    end
    user.resources :conversations, :has_many => [:comments]
    user.resource :avatar, :member => { :micro => :get, :thumb => :get, :profile => :get,:crop => :put }
  end
  
  map.resources :projects,
      :has_many => [:pages,:people],
      :member => [:get_comments,:accept,:decline] do |project|
    #project.hours_by_month 'time_tracking/:year/:month', :controller => 'hours', :action => 'index', :conditions => { :method => :get }
    #project.time_tracking 'time_tracking', :controller => 'hours', :action => 'index'
    project.resources :invitations, :member => [:accept,:decline]
    
    project.resources :comments do |comment|
      comment.resources :uploads, :member => { :iframe => :get }
    end
    project.resources :uploads, :requirements => { :id => /[^\/]+/ }, :member => { :thumbnail => :get }
    
    project.resources :task_lists, :has_many => [:comments], :member => { :reorder => :post } do |task_lists|
      task_lists.resources :tasks, :has_many => [:comments], :member => { :check => :put, :uncheck => :put }
    end
    
    project.resources :people, :member => { :destroy => :get }
    project.resources :conversations, :has_many => [:comments,:uploads]
    project.resources :pages, :has_many => [:notes,:dividers,:task_list,:uploads]
  end
  
  map.resources :comments


  map.root :controller => 'projects', :action => 'index'
  
  SprocketsApplication.routes(map)
end
