ActionController::Routing::Routes.draw do |map|

  # named routes
  map.login      'login', :controller => 'sessions', :action => 'login'
  map.logout     'logout', :controller => 'sessions', :action => 'logout'
  map.signup     'signup', :controller => 'accounts', :action => 'signup'
  map.activation 'activate/:activation_code', :controller => 'accounts', :action => 'activate'
  map.services   'services', :controller => 'application', :action => 'show_services'
  map.about      'about', :controller => 'application', :action => 'show_about'
  map.support    'support', :controller => 'application', :action => 'show_support'
  map.contact    'contact', :controller => 'application', :action => 'show_contact'
  map.eula       'agreement', :controller => 'application', :action => 'show_eula'
  map.dashboard  'dashboard', :controller => 'dashboard', :action => 'index'
  map.error      'error/:code', :controller => 'application', :action => 'error'

  # specific named restful routes
  map.formatted_zone_detail 'zones/:origin.:format', :controller => 'zones', :action => 'show_by_origin', :conditions => { :method => :get }, :requirements => { :origin => /([a-z0-9-]+)\.[a-z.]+/ }
  map.zone_detail 'zones/:origin', :controller => 'zones', :action => 'show_by_origin', :conditions => { :method => :get }, :requirements => { :origin => /([a-z0-9-]+)\.[a-z.]+/ }

  # restful routes
  map.resources :accounts
  map.resources :zones
  map.resource :session

  # root route
  map.root :controller => 'application'

  # default routes
  map.connect  ':controller/:action/:id'
  map.connect  ':controller/:action/:id.:format'

end
