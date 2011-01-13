class AddSsoFacebookIdToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :sso_facebook, :string
    add_index :accounts, [:sso_facebook, :deleted_at], :unique => true
  end
  
  def self.down
    remove_index :accounts, [:sso_facebook, :deleted_at]
    remove_column :accounts, :sso_facebook
  end
end
