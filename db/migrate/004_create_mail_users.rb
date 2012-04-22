class CreateMailUsers < ActiveRecord::Migration
  def self.up
    execute "CREATE TABLE mail_users (
               id            SERIAL8 PRIMARY KEY,
               user_id       INT8 NOT NULL REFERENCES users,
               dns_resource_id INT8 NOT NULL REFERENCES dns_resources,
               name          VARCHAR(255) NOT NULL,
               username      VARCHAR(255) NOT NULL,
               password      VARCHAR(255) NOT NULL,
               quota_bytes   INT8 NOT NULL,
               spam_thrsh    INT4 NOT NULL DEFAULT '5' CHECK (spam_thrsh >= 0 AND spam_thrsh <= 10))"
  end

  def self.down
    drop_table :mail_users
  end
end
