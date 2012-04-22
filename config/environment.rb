ENV['RAILS_ENV'] = 'development'

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.load_paths += %W( #{RAILS_ROOT}/lib )
  config.action_controller.session_store = :active_record_store
end

#CGI::Session::ActiveRecordStore::Session.set_table_name "evilserve.sessions" 

require 'facets/crypt'
