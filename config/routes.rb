EdivaApp::Application.routes.draw do

  match ':controller(/:action(/:id))(.:format)'
  root :to => 'users#index'
  match "index", :to => 'users#index'  #Actual home page of ediva
  match "EULA", :to => 'users#EULA'
  match "about", :to => 'users#about'
  match "contact", :to => 'users#contact'
  match "home", :to => 'eapp#home'
  match "analysis", :to => 'aapp#analysis'
  match "annotate", :to => 'aapp#annotate'
  match "rank", :to => 'aapp#rank'
  match "familyanalysis", :to => 'aapp#familyanalysis'
  match "familyanalysissamples", :to => 'aapp#familyanalysissamples'
  match "docs", :to => 'aapp#docs'
  
  #exceptions pages
  get "/404", :to => "errors#not_found"
  get "/422", :to => "errors#unacceptable"
  get "/500", :to => "errors#internal_error"
  
  
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
