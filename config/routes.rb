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

  map.resources :projects, :has_many => [:invitations,:uploads,:people,:pages] do |project|
    project.time_tracking '/projects/:project_id/time_tracking', :controller => 'hours', :action => 'index'
    
    project.resources :comments do |comment|
      comment.resources :uploads, :member => { :iframe => :get }
      comment.resources :hours
    end

    project.resources :uploads, :requirements => { :id => /[^\/]+/ }, :member => { :thumbnail => :get }

    project.resources :task_lists, :has_many => [:comments] do |task_lists|
      task_lists.resources :tasks, :has_many => [:comments], :member => { :check => :put, :uncheck => :put }
    end

    project.resources :people, :member => { :destroy => :get }
    project.resources :conversations, :has_many => [:comments]
    project.resources :pages, :has_many => [:notes]
  end

  map.root :controller => 'projects', :action => 'index'

  SprocketsApplication.routes(map)
end