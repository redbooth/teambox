ActionController::Routing::Routes.draw do |map|
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.settings '/settings', :controller => 'users', :action => 'edit'
    
  map.resource :session
  

  map.resources :users do |user|
    user.resources :task_lists, :has_many => [:comments] do |task_lists|
      task_lists.resources :tasks, :has_many => [:comments], :member => { :check => :put, :uncheck => :put }
    end
    user.resources :conversations, :has_many => [:comments]
    user.resource :avatar, :member => { :micro => :get, :thumb => :get, :profile => :get,:crop => :put }
  end
    
  map.resources :projects, :has_many => [:comments, :pages] do |project|
    
    project.resources :task_lists, :has_many => [:comments] do |task_lists|
      task_lists.resources :tasks, :has_many => [:comments], :member => { :check => :put, :uncheck => :put }
    end
    project.resources :conversations, :has_many => [:comments]
    project.resources :pages, :has_many => [:notes]
  end
  
  map.resources :comments


  map.root :controller => 'projects', :action => 'index'
  
  SprocketsApplication.routes(map) 
  
end
