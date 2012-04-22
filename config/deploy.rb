require 'mongrel_cluster/recipes'

set :application, "infernalhosting.net"
set :repository, "svn://svn.evilcode.net/sites/#{application}/trunk"

role :web, "web001.evilcode.net"
role :app, "web001.evilcode.net"

set :deploy_to, "/www/infernalhosting.net" # defaults to "/u/apps/#{application}"
set :user, "ryan"            # defaults to the currently logged in user
set :svn_user, "ryan"
set :svn_password, "svnpass4u"

set :mongrel_conf, "#{current_path}/config/mongrel_production.yml"
