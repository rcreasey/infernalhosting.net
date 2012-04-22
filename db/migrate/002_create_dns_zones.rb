class CreateDnsZones < ActiveRecord::Migration
  def self.up
    execute "CREATE TABLE dns_zones (
               id            SERIAL8 PRIMARY KEY,
               user_id       INT8 NOT NULL REFERENCES users,
               origin        VARCHAR(255) NOT NULL UNIQUE,
               ns            VARCHAR(255) NOT NULL,
               mbox          VARCHAR(255) NOT NULL,
               serial        INT8 NOT NULL DEFAULT '1',
               refresh       INT4 NOT NULL DEFAULT '28800',
               retry         INT4 NOT NULL DEFAULT '7200',
               expire        INT4 NOT NULL DEFAULT '604800',
               minimum       INT4 NOT NULL DEFAULT '86400',
               ttl           INT4 NOT NULL DEFAULT '86400')"
  end

  def self.down
    drop_table :dns_zones
  end
end
