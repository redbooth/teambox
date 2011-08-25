Rails.application.routes.draw do

  namespace :api_v2, :path => 'api/2' do
    resources :activities, :only => [:index, :show]
    resources :conversations, :only => [:index]
    resources :threads, :only => [:index, :show]
  end

end
