ActionController::Routing::Routes.draw do |map|  
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.settings '/settings', :controller => 'users', :action => 'edit'
    
  map.resource :session
  
  map.resources :users, :member => { 
                          :comments_descending => :put, 
                          :comments_ascending => :put,
                          :conversations_first_comment => :put,
                          :conversations_latest_comment => :put } do |user|
    user.resources :task_lists, :has_many => [:comments] do |task_lists|
      task_lists.resources :tasks, :has_many => [:comments], :member => { :check => :put, :uncheck => :put }
    end
    user.resources :conversations, :has_many => [:comments]
    user.resource :avatar, :member => { :micro => :get, :thumb => :get, :profile => :get,:crop => :put }
  end
    
  map.resources :projects,
      :has_many => [:pages,:invitations,:people],
      :member => [:get_comments] do |project|
    project.hours_by_month 'time_tracking/:year/:month', :controller => 'hours', :action => 'index', :conditions => { :method => :get }
    project.time_tracking 'time_tracking', :controller => 'hours', :action => 'index'
    project.resources :comments do |comment|
      comment.resources :uploads, :member => { :iframe => :get }
    end
    project.resources :uploads, :requirements => { :id => /[^\/]+/ }, :member => { :thumbnail => :get }
    
    project.resources :task_lists, :has_many => [:comments] do |task_lists|
      task_lists.resources :tasks, :has_many => [:comments], :member => { :check => :put, :uncheck => :put }
    end
    
    project.resources :people, :member => { :destroy => :get }
    project.resources :conversations, :has_many => [:comments,:uploads], :member => { :update_comments => :get }
    project.resources :pages, :has_many => [:notes,:uploads]
  end
  
  map.resources :comments


  map.root :controller => 'projects', :action => 'index'
  
  SprocketsApplication.routes(map)
end
