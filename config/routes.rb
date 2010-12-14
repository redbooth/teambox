Teambox::Application.routes.draw do
  resources :sprockets
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/login' => 'sessions#new', :as => :login
  match '/register' => 'users#create', :as => :register
  match '/signup' => 'users#new', :as => :signup
  match '/search' => 'search#index', :as => :search
  match '/text_styles' => 'users#text_styles', :as => :text_styles
  match '/invite_format' => 'invitations#invite_format', :as => :invite_format
  match '/feeds' => 'users#feeds', :as => :feeds
  match '/calendars' => 'users#calendars', :as => :calendars
  match '/disable_splash' => 'users#disable_splash', :as => :disable_splash
  match '/forgot' => 'reset_passwords#new', :as => :forgot_password
  match '/reset/:reset_code' => 'reset_passwords#reset', :as => :reset_password
  match '/forgetting' => 'reset_passwords#update_after_forgetting', :as => :update_after_forgetting, :method => :put
  match '/reset_password_sent' => 'reset_passwords#sent', :as => :sent_password
  match '/format/:f' => 'sessions#change_format', :as => :change_format
  match '/projects/:project_id/invite/:login' => 'invitations#create', :as => :create_project_invitation, :method => :post
  match '/auth/:provider/callback' => 'auth#callback', :as => :auth_callback
  match '/auth/failure' => 'auth#failure', :as => :auth_failure
  match '/complete_signup' => 'users#complete_signup', :as => :complete_signup
  match '/auth/:provider/unlink' => 'users#unlink_app', :as => :unlink_app
  match '/auth/google' => 'auth#index', :as => :authorize_google_docs, :provider => 'google'

  resources :google_docs do
    collection do
      :search
    end
  end

  match '/i18n/environment.js' => 'javascripts#environment', :as => :javascript_environment
  resources :reset_passwords
  resource :session
  resources :organizations do
    resources :memberships do
      member do
        :change_role
        :add
        :remove
      end
    end
  end

  resources :sites

  match '/account/settings' => 'users#edit', :as => :account_settings, :sub_action => 'settings'
  match '/account/picture' => 'users#edit', :as => :account_picture, :sub_action => 'picture'
  match '/account/profile' => 'users#edit', :as => :account_profile, :sub_action => 'profile'
  match '/account/linked_accounts' => 'users#edit', :as => :account_linked_accounts, :sub_action => 'linked_accounts'
  match '/account/notifications' => 'users#edit', :as => :account_notifications, :sub_action => 'notifications'
  match '/account/delete' => 'users#edit', :as => :account_delete, :sub_action => 'delete'

  match '/account/destroy' => 'users#destroy', :as => :destroy_user
  resources :teambox_datas

  resources :users do
    #RAILS3 - The routes upgrade helper does a terrible job! Revise all routes!
    member do
      get :confirm_email
      get :unconfirmed_email
      get :contact_importer
    end
    resources :conversations
    resources :task_lists do
      resources :tasks
    end
    match 'activities/users/:id/show_more.:format' => 'activities#show_more', :as => :show_more, :method => :get
  end

  match 'activities.:format' => 'activities#show', :as => :activities, :method => :get
  match 'activities/:id/show_new.:format' => 'activities#show_new', :as => :show_new, :method => :get
  match 'activities/:id/show_more.:format' => 'activities#show_more', :as => :show_more, :method => :get
  match 'activities/:id/show_thread.:format' => 'activities#show_thread', :as => :show_thread, :method => :get
  match 'projects/archived.:format' => 'projects#index', :as => :project_archived, :sub_action => 'archived'
  match 'hooks/:hook_name' => 'hooks#create', :as => :hooks, :via => :post

  resources :projects do
    match 'time/:year/:month' => 'hours#index', :as => :hours_by_month, :via => :get
    match 'time/by_period' => 'hours#by_period', :as => :hours_by_period, :via => :get
    match 'time' => 'hours#index', :as => :time
    match 'settings' => 'projects#edit', :as => :settings, :sub_action => 'settings'
    match 'picture' => 'projects#edit', :as => :picture, :sub_action => 'picture'
    match 'deletion' => 'projects#edit', :as => :deletion, :sub_action => 'deletion'
    match 'ownership' => 'projects#edit', :as => :ownership, :sub_action => 'ownership'

    resources :invitations do
      member do
        :accept
        :decline
        :resend
      end
    end

    match 'activities.:format' => 'activities#show', :as => :activities, :method => :get
    match 'activities/:id/show_new.:format' => 'activities#show_new', :as => :show_new, :method => :get
    match 'activities/:id/show_more.:format' => 'activities#show_more', :as => :show_more, :method => :get
    resources :uploads
    match 'hooks/:hook_name' => 'hooks#create', :as => :hooks, :via => :post

    resources :tasks do
      member do
        put :reorder
        put :watch
        put :unwatch
      end
    end

    resources :task_lists do
      resources :tasks do
        member do
          put :watch
          put :unwatch
        end
      end
    end

    match 'contacts' => 'people#contacts', :as => :contacts, :method => :get

    resources :people do
      member do
        get :destroy
      end
    end

    resources :conversations do
      member do
        put :convert_to_task
        put :watch
        put :unwatch
      end
    end

    resources :pages do
      collection do
        post :resort
      end
      member do
        post :reorder
      end
    end

    match 'search' => 'search#index', :as => :search
    resources :google_docs do
      collection do
        :search
      end
    end
  end

  match '/public' => 'public/projects#index', :as => :public_projects
  root :to => 'projects#index'

  namespace :public do
    match ':id' => 'projects#show', :as => :project
    match ':project_id/conversations' => 'conversations#index', :as => :project_conversations
    match ':project_id/conversations/:id' => 'conversations#show', :as => :project_conversation
    match ':project_id/:id' => 'pages#show', :as => :project_page
  end

  match 'api' => 'apidocs#index', :as => :api
  match 'api/concepts' => 'apidocs#concepts', :as => :api_concepts
  match 'api/routes' => 'apidocs#routes', :as => :api_routes
  match 'api/changes' => 'apidocs#changes', :as => :api_changes
  match 'api/:model' => 'apidocs#model', :as => :api_model

  scope 'api/1' do
    namespace :api_v1 do
      resources :projects do
        resources :activities
        resources :people
        resources :comments
        resources :conversations do
          resources :comments
        end
        resources :invitations do
          member do
            put :resend
          end
        end
        resources :task_lists do
          resources :tasks
        end
        resources :tasks do
          resources :comments
        end
        resources :uploads
        resources :pages do
          collection do
            put :resort
          end
          member do
            put :reorder
          end
        end
        resources :notes
        resources :dividers
        match 'search' => 'search#index', :as => :search
      end
      resources :activities
      resources :invitations do
        member do
          put :accept
        end
      end
      resources :users
      resources :tasks do
        member do
          put :watch
          put :unwatch
        end
      end
      resources :comments
      resources :conversations do
        resources :comments
      end
      resources :task_lists do
        resources :tasks
      end
      resources :tasks do
        resources :comments
      end
      resources :uploads
      resources :pages do
        collection do
          put :resort
        end
        member do
          put :reorder
        end
      end
      resources :notes
      resources :dividers
      resources :organizations do
        resources :projects do
          member do
            put :transfer
          end
        end
        resources :memberships
      end
      match 'search' => 'search#index', :as => :search
      match 'account' => 'users#current', :as => :account, :via => :get
    end
  end

  resources :task_lists do
    collection do
      get :gantt_view
    end
  end

  resources :conversations
  match 'time/:year/:month' => 'hours#index', :as => :hours_by_month, :via => :get
  match 'time/by_period' => 'hours#by_period', :as => :hours_by_period, :via => :get
  match 'time' => 'hours#index', :as => :time
  match '/' => 'projects#index'
  match 'assets/:id/:style/:filename' => 'uploads#download', :constraints => { :filename => /.*/ }, :via => :get

  if Rails.env.development?
    mount Emailer::Preview => 'mail_view'
  end
end
