ActionController::Routing::Routes.draw do |map|
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.resources :users
  map.resource :session
  
  map.resources :projects, :has_many => [:comments] do |project|
    project.resources :task_lists, :has_many => [:comments] do |task_lists|
      task_lists.resources :tasks, :has_many => [:comments], :member => { :check => :put, :uncheck => :put }
    end
    
    project.resources :conversations, :has_many => [:comments]
    project.resources :pages, :member => { :rename => :get, :section_divider => :get } do |pages|
      pages.resources :dividers
    end
  end
  
  map.resources :comments

  map.root :controller => 'projects', :action => 'index'
  
  SprocketsApplication.routes(map) 
  
end
