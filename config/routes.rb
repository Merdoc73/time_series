Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'web/home#index'
  namespace :api do
    resource :base_graph
    resource :deviation_graph
  end
end
