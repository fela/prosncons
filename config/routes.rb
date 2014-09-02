Prosncons::Application.routes.draw do

  mount RailsAdmin::Engine => '/aadmin', as: 'rails_admin'
  root :to => 'home#index'
  get 'faq' => 'home#faq'

  resources :users
  #resource :session

  post 'persona/:action', controller: :persona
  get 'persona/new_user' => 'persona#new_user'

  resources :pages do
    resources :comments
  end

  get 'pages/:page_id/versions' => 'pages#versions', as: :versions_page

  put 'pages/:page_id/arguments/:id/vote/:vote_type' => 'arguments#vote'

  get 'pages/:page_id/arguments/:option/new' => 'arguments#new'
  post 'pages/:page_id/arguments/:option' => 'arguments#create'
  get 'pages/:page_id/arguments/:option/:id/edit' => 'arguments#edit'
  put 'pages/:page_id/arguments/:option/:id' => 'arguments#update'
  get 'pages/:page_id/arguments/:option/:id/versions' => 'arguments#versions'

  # XXX: what is the difference between arguments#vote and votes#create?
  post 'pages/votes/:argument_id/:vote' => 'votes#create'

  #get 'pages/:page_id/comments' => 'comments#index'
  #get 'pages/:page_id/comments/new' => 'comments#new'
  #post 'pages/:page_id/comments' => 'comments#create'

  get 'pages/:page_id/arguments/:id/comments' => 'comments#index'
  get 'pages/:page_id/arguments/:id/comments/new' => 'comments#new'
  post 'pages/:page_id/arguments/:id/comments' => 'comments#create'


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
