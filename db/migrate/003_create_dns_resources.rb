class CreateDnsResources < ActiveRecord::Migration
  def self.up
    execute "CREATE DOMAIN dns_resource_type AS VARCHAR(5) CHECK (VALUE IN
              ('A', 'AAAA', 'CNAME', 'HINFO', 'MX', 'NS', 'PTR', 'SRV', 'TXT'))"

    execute "CREATE TABLE dns_resources (
               id            SERIAL8 PRIMARY KEY,
               dns_zone_id   INT8 NOT NULL REFERENCES dns_zones,
               name          VARCHAR(64) NOT NULL,
               type          DNS_RESOURCE_TYPE NOT NULL,
               data          VARCHAR(255) NOT NULL,
               aux           INT4 NULL DEFAULT NULL,
               ttl           INT4 NULL DEFAULT NULL)"
  end

  def self.down
    drop_table :dns_resources
    execute "DROP DOMAIN dns_resource_type"
  end
end
