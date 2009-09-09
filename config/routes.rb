ActionController::Routing::Routes.draw do |map|
  map.upload_iframe '/projects/:project_id/:target_type/uploads', :controller => 'uploads', :action => 'iframe',
    :conditions => { :method => :get }
  map.upload_iframe '/projects/:project_id/:target_type/uploads', :controller => 'uploads', :action => 'create',
    :conditions => { :method => :post }  
  
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.settings '/settings', :controller => 'users', :action => 'edit'
    
  map.resource :session
  

  map.resources :users do |user|
    user.resources :task_lists, :has_many => [:comments,:uploads] do |task_lists|
      task_lists.resources :tasks, :has_many => [:comments,:uploads], :member => { :check => :put, :uncheck => :put }
    end
    user.resources :conversations, :has_many => [:comments,:uploads]
    user.resource :avatar, :member => { :micro => :get, :thumb => :get, :profile => :get,:crop => :put }
  end
    
  map.resources :projects, :has_many => [:invitations,:uploads] do |project|
    project.resources :comments, :has_many => [:uploads]
    project.resources :pages, :has_many => [:uploads]
    
    project.resources :uploads, :requirements => { :id => /[^\/]+/ }, :member => { :thumbnail => :get }
    
    project.resources :task_lists, :has_many => [:comments,:uploads] do |task_lists|
      task_lists.resources :tasks, :has_many => [:comments,:uploads], :member => { :check => :put, :uncheck => :put }
    end
    
    project.resources :conversations, :has_many => [:comments,:uploads]
    project.resources :pages, :has_many => [:notes,:uploads]
  end
  
  map.resources :comments


  map.root :controller => 'projects', :action => 'index'
  
  SprocketsApplication.routes(map)
end
