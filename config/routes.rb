ActionController::Routing::Routes.draw do |map|
  map.splash 'splash', :controller => 'application', :action => 'show_splash'

  # panel routes
  map.connect 'domain/:action', :controller => 'domain' 

  map.connect 'panel/', :controller => 'panel' 
  map.connect 'panel/:origin/dns/:action', :controller => 'dns', :requirements => { :origin => /[-\w]+(\.[-\w]*)+/ }
  map.connect 'panel/:origin/site/:action/:id', :controller => 'web', :requirements => { :origin => /[-\w]+(\.[-\w]*)+/ } 
  map.connect 'panel/:origin/web/:action/:id', :controller => 'web', :requirements => { :origin => /[-\w]+(\.[-\w]*)+/ } 
  map.connect 'panel/:origin/db/:action/:id', :controller => 'web', :requirements => { :origin => /[-\w]+(\.[-\w]*)+/ } 
  map.connect 'panel/:origin/mail/:action/:id', :controller => 'mail', :requirements => { :origin => /[-\w]+(\.[-\w]*)+/ } 
  map.connect 'panel/:origin/:action', :controller => 'domain', :requirements => { :origin => /[-\w]+(\.[-\w]*)+/ } 

  # login routes
  map.logout 'logout', :controller => 'login', :action => 'logout'

  # error routes
  map.error_404 'error/404', :controller => 'error', :action => 'error_404'
  map.error_503 'error/503', :controller => 'error', :action => 'error_503'

  map.splash '', :controller => 'application', :action => 'show_splash'

  # default routes
  map.home ':controller/:action/:id', :controller => 'main'
  map.connect ':controller/:action/:id'
end
