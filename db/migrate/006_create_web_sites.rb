class CreateWebSites < ActiveRecord::Migration
  def self.up
    execute "CREATE TABLE web_sites (
               id            SERIAL8 PRIMARY KEY,
               user_id       INT8 NOT NULL REFERENCES users,
               dns_resource_id INT8 NOT NULL REFERENCES dns_resources,
               serveradmin   VARCHAR(255) NOT NULL,
               quota_bytes   INT8 NOT NULL)"
  end

  def self.down
    drop_table :web_sites
  end
end
