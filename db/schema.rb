# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 1) do

  create_table "accounts", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email_address"
    t.string   "phone_number",              :limit => 15
    t.string   "login"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                   :default => "passive"
    t.datetime "deleted_at"
  end

  create_table "dns_resource_types", :force => true do |t|
    t.string "type",        :null => false
    t.text   "description"
  end

  create_table "dns_resources", :force => true do |t|
    t.integer "dns_zone_id",                        :null => false
    t.integer "dns_resource_type_id",               :null => false
    t.string  "name",                 :limit => 64, :null => false
    t.string  "data",                               :null => false
    t.integer "aux"
    t.integer "ttl"
  end

  create_table "dns_zones", :force => true do |t|
    t.string  "origin",                      :null => false
    t.string  "ns",                          :null => false
    t.string  "mbox",                        :null => false
    t.integer "serial",                      :null => false
    t.integer "refresh", :default => 10800,  :null => false
    t.integer "retry",   :default => 3600,   :null => false
    t.integer "expire",  :default => 604800, :null => false
    t.integer "ttl",     :default => 3600,   :null => false
  end

  add_index "dns_zones", ["origin"], :name => "dns_zones_origin_key", :unique => true

end
