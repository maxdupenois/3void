Void::Application.routes.draw do
  # You can have the root of your site routed with "root"
  root 'application#index'
  mount MarkdownArticles::Engine, at: '/articles', as: 'marticles'
  resources :projects
  resource :academic, controller: 'academic'
end
