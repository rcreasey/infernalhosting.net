class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts, :force => true do |t|
      t.column :first_name,                :string
      t.column :last_name,                 :string
      t.column :email_address,             :string
      t.column :phone_number,              :string, :limit => 15
      t.column :login,                     :string

      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :activation_code, :string, :limit => 40
      t.column :activated_at, :datetime
      t.column :state, :string, :null => :no, :default => 'passive'
      t.column :deleted_at, :datetime
    end
  end

  def self.down
    drop_table :accounts
  end
end
