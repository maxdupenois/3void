Void::Application.routes.draw do
  # You can have the root of your site routed with "root"
  root 'application#index'
  mount Marti::Engine, at: '/articles', as: 'marti'
  resources :projects
  resource :academic, controller: 'academic'
  match "/404", to: "errors#not_found", via: [:get, :post, :patch, :delete]
end
