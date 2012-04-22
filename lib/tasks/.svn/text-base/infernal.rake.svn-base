namespace :infernal do
  namespace :pgsql do 
    desc "Starts the pgsql database."
    task :start do
      `sudo -u pgsql /usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data start`
    end
    
  end
  
  namespace :mongrel do
    desc "Starts mongrel worker."
    task :start do 
      `mongrel_rails cluster::start --clean -C config/mongrel_development.yml`
    end
  end
end
