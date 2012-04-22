class CreateMailAliases < ActiveRecord::Migration
  def self.up
    execute "CREATE TABLE mail_aliases (
               id            SERIAL8 PRIMARY KEY,
               user_id       INT8 NOT NULL REFERENCES users,
               dns_resource_id INT8 NOT NULL REFERENCES dns_resources,
               username      VARCHAR(255) NOT NULL,
               destination   VARCHAR(255) NOT NULL)"
  end

  def self.down
    drop_table :mail_aliases
  end
end
