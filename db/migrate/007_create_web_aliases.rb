class CreateWebAliases < ActiveRecord::Migration
  def self.up
    execute "CREATE TABLE web_aliases (
               id            SERIAL8 PRIMARY KEY,
               web_site_id   INT8 NOT NULL REFERENCES web_sites,
               dns_resource_id INT8 NOT NULL REFERENCES dns_resources)"
  end

  def self.down
    drop_table :web_aliases
  end
end
