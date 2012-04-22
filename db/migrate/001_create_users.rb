class CreateUsers < ActiveRecord::Migration
  def self.up
    execute "CREATE TABLE users (
               id            SERIAL8 PRIMARY KEY,
               name          VARCHAR(255) NOT NULL,
               username      VARCHAR(255) NOT NULL UNIQUE,
               password      VARCHAR(255) NOT NULL,
               created_on    TIMESTAMP NOT NULL DEFAULT NOW())"
  end

  def self.down
    drop_table :users
  end
end
